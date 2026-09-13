# Desktop-stack selection: hand-rolled Hyprland vs omarchy-nix's module,
# plus the two additive "extra GDM session" toggles. Split out of
# flake.nix to keep that file to inputs/outputs plumbing.
#
# ---------------------------------------------------------------------
# Omarchy toggle
#
# false (default): the hand-rolled desktop stack (desktop/hyprland.nix +
#   desktop/waybar.nix + theme/theme-switcher.nix + desktop/desktop-local.nix
#   + m.niri) and the shared ghostty/zsh/zoxide modules are used, exactly
#   as before.
# true: all of that is dropped and replaced by omarchy-nix's opinionated
#   home-manager module (Hyprland, waybar, wofi, hyprlock, ghostty, zsh,
#   zoxide, starship, mako, btop, theming, ...).
#
# Still owned by this repo's config even when omarchy is on, so watch
# for clashes: home/shell-programs.nix's oh-my-posh (vs omarchy's
# starship), vim / doom-emacs (vs omarchy's bare neovim), wezterm, foot.
#
# Flipping this on ALSO needs the system side: flip `enableOmarchy` in
# ./nixos/flake.nix and reconcile the conflicts listed in
# ./nixos/omarchy.nix, then `nixos-switch`. omarchy-nix targets
# nixos-unstable; it is pinned to nixos-26.05 here via `follows`, so
# expect to iterate if upstream uses something newer than 26.05 ships.
# ---------------------------------------------------------------------
{ lib, m, home-manager, nixpkgs, omarchy-nix ? null, omarchy4 ? null }:

let
  enableOmarchy = false;

  # Separate, additive "Omarchy" GDM session that sits NEXT TO the normal
  # Hyprland session (unlike `enableOmarchy` above, which replaces it).
  # Vendors omarchy-nix's config tree into ~/.config-omarchy and adds a
  # launcher; the GDM entry is registered in nixos/omarchy-session.nix
  # (needs `nixos-switch` once). See ../omarchy-session.nix.
  enableOmarchySession = true;

  omarchySessionModule =
    import ../omarchy-session.nix { inherit home-manager omarchy-nix nixpkgs; };

  # EXPERIMENTAL — the real upstream Omarchy 4 ("Quattro") desktop, run
  # isolated in ~/.config-omarchy4 as its own GDM session, NEXT TO
  # everything else (independent of `enableOmarchy` /
  # `enableOmarchySession`, which both use omarchy-nix's older
  # Omarchy-3-era stack). Needs the GDM entry from nixos/omarchy4/
  # registered once via `nixos-switch`.
  # See ../omarchy4/README.md for what works and what doesn't.
  enableOmarchy4Session = true;

  omarchy4SessionModule = import ../omarchy4 { inherit omarchy4; };

  # Hand-rolled desktop stack — used only when the toggle is off.
  customDesktopModules = [
    ../desktop/hyprland.nix
    ../desktop/waybar.nix
    ../theme/theme-switcher.nix
    ../desktop/desktop-local.nix
    m.niri
  ];

  # Shared shell/terminal modules that omarchy-nix's home-manager module
  # also configures. Kept in their original list positions in flake.nix
  # (via `withoutOmarchy`) so the toggle-off build is unchanged; omarchy
  # owns these when the toggle is on.
  withoutOmarchy = mod: lib.optional (!enableOmarchy) mod;

  omarchyModules = [
    omarchy-nix.homeManagerModules.default
    {
      # `m.zsh` normally provides the `hm` / rebuild aliases; keep them
      # when omarchy's own zsh config takes over.
      programs.zsh.shellAliases.hm =
        "home-manager switch --impure --flake ~/.config/home-manager#$USER@$(hostname)";

      # omarchy enables a bare, unconfigured `programs.neovim` ("TODO:
      # Add an actual nvim config" upstream). macnix already installs
      # its own `pkgs.neovim` in home/packages.nix and sets EDITOR=nvim —
      # the two collide on `bin/nvim` in the profile. Keep macnix's.
      programs.neovim.enable = lib.mkForce false;

      # home-manager 26.05 defaults Hyprland `configType` to "lua", but
      # omarchy-nix's module is written for the "hyprlang" style — it
      # sets `settings.$terminal = "ghostty"` etc., which the lua writer
      # renders as `hl.$terminal("ghostty")`. `$` is invalid in a Lua
      # identifier, so Hyprland fails to parse the whole config and
      # falls back to keybind-less defaults (Super+Return does nothing).
      # Force the native hyprland.conf writer, where `$terminal = ...`
      # is valid. (The repo's own desktop/hyprland.nix, dropped when
      # omarchy is on, is what actually needs lua — so this only
      # applies here.)
      wayland.windowManager.hyprland.configType = lib.mkForce "hyprlang";
    }
    {
      # omarchy-nix's home-manager module is written to run as part of a
      # NixOS system: it pulls its `omarchy.*` settings from
      # `osConfig.omarchy`, and hyprland/envs.nix reads
      # `osConfig.services.xserver.videoDrivers`. In this repo's
      # standalone home-manager setup `osConfig` is `null`, so we shim a
      # minimal one here. macnix is Intel-graphics only, so the NVIDIA
      # env branch resolves to false.
      _module.args.osConfig = {
        services.xserver.videoDrivers = [ ];
        omarchy = {
          full_name = "Rúni H.Hansen";
          email_address = "runi.hansen@okkara.net";
          theme = "tokyo-night";
          scale = 2;
        };
      };
    }
  ];

  desktopModules = if enableOmarchy then omarchyModules else customDesktopModules;
in
{
  inherit
    enableOmarchy
    enableOmarchySession
    omarchySessionModule
    enableOmarchy4Session
    omarchy4SessionModule
    withoutOmarchy
    desktopModules;
}
