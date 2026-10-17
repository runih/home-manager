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
#
# Known harmless eval warnings from this nested build, all sourced from
# the pinned omarchy-nix input's own code, not from anything in this
# repo:
#   - "'system' has been renamed to/replaced by
#     'stdenv.hostPlatform.system'" — fixed below by overriding
#     `wayland.windowManager.hyprland.package` AND `.portalPackage`.
#     nixpkgs 26.05 turned `pkgs.system` into a `warnAlias` for
#     `pkgs.stdenv.hostPlatform.system` (pkgs/top-level/aliases.nix), so
#     merely forcing `pkgs.system` anywhere fires the trace. Two
#     independent things force it here, and both had to be overridden
#     before the warning actually went away (confirmed by bisecting with
#     `nix eval .#homeConfigurations."runih@macnix".activationPackage
#     .drvPath`, which evaluates fast enough to iterate on without a full
#     `hm` run each time):
#       1. omarchy-nix's modules/home-manager/hyprland.nix sets
#          `wayland.windowManager.hyprland.package =
#          inputs.hyprland.packages.${pkgs.system}.hyprland;` directly —
#          this is the obvious one.
#       2. Less obviously, home-manager's own hyprland.nix declares
#          `portalPackage = lib.mkPackageOption pkgs
#          "xdg-desktop-portal-hyprland" { nullable = true; };` — omarchy
#          doesn't touch this option at all, so it's left at home-manager's
#          *default*, and `mkPackageOption`'s nullable-availability check
#          forces `pkgs.system` internally to decide if the package exists
#          on this platform. `cfg.finalPortalPackage` (read by
#          `xdg.portal.enable`/`extraPortals`/`configPackages`, all inside
#          hyprland.nix's `config = mkIf cfg.enable {...}`) is what forces
#          it — which is also why temporarily disabling
#          `wayland.windowManager.hyprland.enable` entirely (an earlier,
#          reverted attempt) made the warning go away too: it stopped that
#          whole `mkIf` block, portalPackage included, from running at
#          all. Don't reuse that approach — it would also skip the
#          `config = mkIf cfg.enable {...}` block's `xdg.configFile."hypr/
#          hyprland.conf"` generation, which is the one thing this nested
#          build exists to produce.
#     `lib.mkForce` on both options means the option merge picks our
#     definition outright and never forces the discarded lower-priority
#     one, so `pkgs.system` is never read from either path. (Overriding
#     `pkgs.system` itself, e.g. via the `pkgs` passed into
#     `homeManagerConfiguration` below, does NOT work: home-manager's own
#     modules/misc/nixpkgs.nix unconditionally rebuilds `pkgs` from
#     scratch via `import pkgsPath {...}` at a higher module-system
#     priority, so that override doesn't stick — this is why the fix
#     targets the *consumers* of `pkgs.system` instead.) Neither override
#     changes anything we actually use this nested build for: setting
#     `package` to `pkgsUnstable.hyprland` matches the real session (which
#     already runs that same derivation) and only affects config-
#     generation logic gated on `cfg.package`, if any; `portalPackage`
#     being `null` only disables `xdg.portal.*` wiring, which isn't part
#     of `config.home-files` either.
#     (modules/packages.nix also has a `pkgs.system == "x86_64-linux"`
#     check, but it feeds `packages.systemPackages`, which only the NixOS
#     side of omarchy-nix consumes — modules/home-manager/default.nix
#     only reads `packages.homePackages` (hardcoded to `[ ]` upstream), so
#     that branch is unreachable from this nested home-manager-only build
#     and needs no override.)
#   - "The option `programs.git.userName'/... has been renamed" —
#     silenced below with `warnings = lib.mkForce [ ];`. omarchy-nix's
#     modules/home-manager/git.nix sets the old-style
#     `programs.git.userName`/`userEmail`/`extraConfig` options
#     unconditionally (not inside any `mkIf cfg.enable`), so
#     `mkRenamedOptionModule`'s renamed-option submodule sees those
#     options as *defined* and appends the warning string to
#     `config.warnings` regardless of `cfg.enable` — tried forcing
#     `programs.git.enable = false` first; didn't help, because
#     `isDefined` is a structural fact about whether any module sets the
#     option, not about whether something reads the value afterwards.
#     Forcing `config.warnings` itself to `[ ]` is the one override that
#     actually reaches it: home-manager prints every entry in that list
#     the moment `config.home-files` (or any other config.* leaf we pull
#     from this nested build) gets forced, with no way to scope it to
#     just the git-related entries. Safe here because this whole nested
#     `omarchyConf` only exists to render a dotfile tree we copy
#     ourselves — any real misconfiguration in it would show up as a
#     build failure, not a warning, so there is nothing this would hide.
#     `disabledModules` can't be used instead to exclude the git.nix
#     submodule outright: omarchy-nix's own aggregator wraps each file in
#     `(import ./foo.nix)` before adding it to `imports`, which loses the
#     path identity `disabledModules` matches on. Harmless either way:
#     the top-level ~/.gitconfig that module would produce is never
#     consumed here — only the `.config` subtree of
#     `omarchyConf.config.home-files` is copied into ~/.config-omarchy
#     below.

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

        # Silences the "programs.git.userName'/... has been renamed"
        # warnings from omarchy-nix's git.nix — see the note up top.
        warnings = lib.mkForce [ ];

        # Silences the "'system' has been renamed..." warning — see the
        # note up top. Matches the real session's Hyprland version.
        wayland.windowManager.hyprland.package = lib.mkForce pkgsUnstable.hyprland;
        wayland.windowManager.hyprland.portalPackage = lib.mkForce null;

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
