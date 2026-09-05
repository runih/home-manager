# A second, self-contained "Omarchy" desktop that shows up in GDM next to
# the hand-rolled Hyprland session — pick either at login.
#
# How it works:
#   * omarchy-nix's home-manager module is evaluated in a NESTED
#     `homeManagerConfiguration` here (not merged into the real macnix
#     config), purely to render omarchy's generated dotfile tree.
#   * That tree is patched for an older Hyprland — omarchy targets a newer
#     one and uses a few option/keyword names older builds reject — then
#     dropped into ~/.config-omarchy/. The launcher now runs the same
#     pkgsUnstable.hyprland (0.56.2) as the rest of macnix; the patch below
#     is kept because it stays harmless there (worst case a couple of
#     cosmetic rules are dropped). Eyeball this session at login after a
#     Hyprland bump.
#   * A launcher script points XDG_CONFIG_HOME at ~/.config-omarchy and
#     starts Hyprland, so its whole stack (waybar, wofi, mako, hyprlock,
#     ghostty, gtk) reads omarchy's config while the normal Hyprland
#     session keeps using ~/.config untouched.
#   * The GDM entry itself is registered system-side in
#     nixos/omarchy-session.nix (services.displayManager.sessionPackages).
#
# This is deliberately a vendored snapshot, not a live omarchy install:
# omarchy-nix proper needs a full nixos-unstable system. Regenerates on
# every `hm`; bump omarchy-nix in the root flake to update it.

{ home-manager, omarchy-nix, nixpkgs }:
{ pkgs, pkgsUnstable, lib, username, homeDirectory, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  # omarchy's HM module, evaluated standalone. Only `config.home-files`
  # (the generated ~/.config tree) is consumed — none of omarchy's
  # packages or profile end up in the real macnix generation.
  omarchyConf = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    modules = [
      omarchy-nix.homeManagerModules.default
      ({ lib, ... }: {
        home.username = username;
        home.homeDirectory = homeDirectory;
        home.stateVersion = "26.05";

        # Emit hyprland.conf, not hyprland.lua — omarchy is written for the
        # hyprlang writer (see the note in ../flake.nix).
        wayland.windowManager.hyprland.configType = lib.mkForce "hyprlang";
        programs.neovim.enable = lib.mkForce false;

        _module.args.osConfig = {
          services.xserver.videoDrivers = [ ];
          omarchy = {
            full_name = "Rúni H.Hansen";
            email_address = "runi.hansen@okkara.net";
            theme = "tokyo-night";
            scale = 2;
          };
        };
      })
    ];
  };

  # Patch omarchy's hyprland.conf for an older Hyprland (still applied on
  # 0.56.2 — harmless there):
  #   - `togglesplit` is a layoutmsg, not a bare dispatcher, in this build
  #   - decoration:shadow:ignore_window / dwindle:pseudotile /
  #     gestures:workspace_swipe were renamed or removed upstream
  #   - this build wants the `windowrulev2` keyword for field-matched rules
  #   - `layerrule=blur,*` is rejected here (cosmetic — drop it)
  # Also swap omarchy's hardcoded `kb_layout=us` for this MacBook's
  # `macnix-se` layout (nixos/keyboard.nix) — without it some keycodes on
  # the internal keyboard are wrong.
  omarchyTree = pkgs.runCommand "omarchy-config-tree" { } ''
    cp -rL --no-preserve=mode,ownership ${omarchyConf.config.home-files} $out
    conf=$out/.config/hypr/hyprland.conf
    ${pkgs.gnused}/bin/sed -i -E \
      -e 's|^bind=SUPER, J, togglesplit,.*|bind=SUPER, J, layoutmsg, togglesplit|' \
      -e '/^[[:space:]]*ignore_window[[:space:]]*=/d' \
      -e '/^[[:space:]]*pseudotile[[:space:]]*=/d' \
      -e '/^layerrule=blur,/d' \
      -e 's|^windowrule=|windowrulev2=|' \
      -e 's|^([[:space:]]*)kb_layout=.*|\1kb_layout=macnix-se\n\1kb_model=apple|' \
      -e 's|^([[:space:]]*)kb_options=.*|\1kb_options=lv3:lalt_switch,apple:alupckeys|' \
      "$conf"
    ${pkgs.gnused}/bin/sed -i -E '/^gestures[[:space:]]*\{/,/^\}/d' "$conf"
  '';

  # nixos/omarchy-session.nix registers a GDM entry whose Exec is the fixed
  # path ~/.local/bin/omarchy-hyprland (below), so the two sides don't need
  # to share a store path.
  omarchyLauncher = pkgs.writeShellScript "omarchy-hyprland" ''
    export XDG_CONFIG_HOME="$HOME/.config-omarchy"
    export XDG_CURRENT_DESKTOP=Hyprland
    exec ${pkgsUnstable.hyprland}/bin/Hyprland
  '';
in
{
  home.file.".config-omarchy" = {
    source = "${omarchyTree}/.config";
    recursive = true;
  };

  home.file.".local/share/omarchy" = {
    source = "${omarchyTree}/.local/share/omarchy";
    recursive = true;
  };

  home.file.".local/bin/omarchy-hyprland" = {
    source = omarchyLauncher;
    executable = true;
  };
}
