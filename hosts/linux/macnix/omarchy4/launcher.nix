# ~/.local/bin/omarchy4-session — the GDM session Exec (fixed path, so the
# system .desktop in nixos/omarchy4/ can point at it). Sets OMARCHY_PATH +
# XDG_CONFIG_HOME=~/.config-omarchy4, fixes PATH, and execs start-hyprland.
#
# The script body is kept byte-for-byte as it was in the old
# omarchy4-session.nix so the `omarchy4-session` store path does not move.

{ pkgs, pkgsUnstable, lib, omarchyTree, runtimeDeps, configHome, username }:

pkgs.writeShellScript "omarchy4-session" ''
    # GDM runs this .desktop Exec with a bare PATH and none of the
    # home-manager session vars, so `hm` / `nix` / user tools are missing
    # inside the session. Pull them in first.
    [ -r "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && \
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

    # XDG_CONFIG_HOME below also redirects `nix`'s own config lookup, and
    # ~/.config-omarchy4/nix/nix.conf doesn't exist — so `nix` / `hm` would
    # lose `experimental-features` and every other setting. Pin the real
    # user nix.conf explicitly (a ~/.config-omarchy4/nix -> ~/.config/nix
    # symlink from the HM module backs this up).
    export NIX_USER_CONF_FILES="$HOME/.config/nix/nix.conf"

    export OMARCHY_PATH="${omarchyTree}"
    export XDG_CONFIG_HOME="${configHome}"
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_SESSION_TYPE=wayland

    # Omarchy 4's LazyVim ("omarchy-nvim"), namespaced away from the user's
    # real ~/.config/nvim: every nvim/neovide in this session uses
    # ~/.config-omarchy4/omarchy-nvim + ~/.local/{share,state}/omarchy-nvim +
    # ~/.cache/omarchy-nvim. See nvimConfig / the home.file entries.
    export NVIM_APPNAME=omarchy-nvim

    # Quickshell's Qt build bundles qtsvg but NOT qtimageformats, so it
    # can't decode .webp — which is the format of nearly every Omarchy
    # theme background ("Unsupported image format" in the shell log, and
    # the wallpaper never changes). Add the matching-version image-format
    # plugins; Qt merges this with its built-in plugin path.
    export QT_PLUGIN_PATH="${pkgs.qt6.qtimageformats}/lib/qt-6/plugins''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
    # /run/wrappers/bin FIRST — it holds the setuid wrappers (sudo, su,
    # mount, …). Stock NixOS keeps it ahead of /run/current-system/sw/bin,
    # whose `sudo` is a plain non-setuid copy; if that wins, `sudo` (and so
    # `nixos-switch`) dies with "must be owned by uid 0 and have the setuid
    # bit set" inside this session. Then $OMARCHY_PATH/bin (Omarchy's own
    # CLI), the Nix runtime deps, the user + system profiles, and finally
    # whatever we inherited.
    export PATH="/run/wrappers/bin:${omarchyTree}/bin:${lib.makeBinPath runtimeDeps}:$HOME/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin''${PATH:+:$PATH}"

    # start-hyprland (not the raw Hyprland binary) is Hyprland's supported
    # entry point — watchdog + crash-restart + systemd/dbus session setup.
    # Matches this box's normal "Hyprland" GDM session and silences
    # "launched without start-hyprland". Same pkgsUnstable.hyprland (0.56.2)
    # as the system compositor and hyprland.nix.
    exec ${pkgsUnstable.hyprland}/bin/start-hyprland
  ''
