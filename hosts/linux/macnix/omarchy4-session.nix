# EXPERIMENTAL — run the REAL upstream Omarchy 4 ("Quattro") desktop on this
# NixOS box, isolated in ~/.config-omarchy4, as its own GDM session next to
# the normal Hyprland / Niri / (omarchy-nix) Omarchy entries.
#
# Why this exists separately from ../omarchy-session.nix:
#   ../omarchy-session.nix vendors *omarchy-nix*'s generated dotfiles — an
#   Omarchy-3-era stack (waybar + walker + mako + hyprlock). Omarchy 4 threw
#   all of that out for one long-running Quickshell process. omarchy-nix has
#   not been ported to it and is unmaintained, so this module points at
#   upstream `github:omacom/omarchy` directly instead.
#
# How it works:
#   * The upstream repo IS the runtime. There is no "generated tree": we take
#     the checkout, patch its 700+ `#!/bin/bash` / `#!/usr/bin/python3`
#     shebangs (no /bin/bash or /usr/bin/python3 on NixOS), and drop the
#     result in the store as $OMARCHY_PATH.
#   * A launcher (~/.local/bin/omarchy4-session, fixed path so the system
#     .desktop in nixos/omarchy4-session.nix can point at it) exports
#     OMARCHY_PATH + XDG_CONFIG_HOME=~/.config-omarchy4, puts $OMARCHY_PATH/bin
#     and the Nix runtime deps on PATH, and execs Hyprland.
#   * Hyprland reads ~/.config-omarchy4/hypr/hyprland.lua, which `dofile`s
#     $OMARCHY_PATH/default/hypr/bootstrap.lua and pulls in Omarchy's Lua
#     defaults; its autostart launches `omarchy-launch-shell` → Quickshell.
#   * The normal Hyprland session (~/.config/hypr, hosts/.../hyprland.nix) is
#     untouched — different XDG_CONFIG_HOME, different config tree.
#
# WHAT WORKS (best case, expect to iterate on-device):
#   the compositor, the Quickshell bar / menu / launcher / lock, and the
#   theming that ships inside the repo (tokyo-night is the default).
#
# WHAT DOES NOT:
#   * every menu action that shells out to pacman / yay / snapper / limine /
#     `systemctl` as root — install, update, rollback, most of the "system"
#     menu. Those are Arch + Omarchy-ISO assumptions with no equivalent here;
#     do that stuff through this repo's Nix config instead.
#   * `o.launch()` app keybinds wrap the command in `uwsm-app`; this launcher
#     starts Hyprland directly, not under uwsm, so those may not fire. Switch
#     the launcher to `uwsm start` if it matters.
#   * first-run/provisioning hooks, mise, voxtype, fingerprint, etc.
#
# VERSION SKEW (the real risk): nixos-26.05 ships Hyprland 0.55.4 and
# Quickshell 0.3.0; Omarchy 4 tracks whatever Arch shipped at its release.
# Hyprland's Lua config API and Quickshell's QML API both move fast — if the
# bar won't render or Hyprland rejects the config, that's almost certainly
# why. Bump the `omarchy4` input / try newer pkgs and re-test.

{ omarchy4 }:

{ pkgs, lib, config, username, homeDirectory, ... }:

let
  configHome = "${homeDirectory}/.config-omarchy4";

  # Tools the bin/omarchy-* scripts and the Hyprland/Quickshell configs call
  # that DO have a nixpkgs equivalent. Arch-only ones (pacman, yay, snapper,
  # limine, mise-bin, asdcontrol, expac, ...) are deliberately absent — the
  # scripts that need them will fail, and that's covered above.
  runtimeDeps = with pkgs; [
    hyprland                # hyprctl, and the compositor the launcher execs
    hyprland-qtutils        # hyprland-dialog / hyprland-toast used by scripts
    hypridle
    hyprsunset
    hyprpicker
    quickshell              # `qs` + `quickshell`, the Omarchy 4 shell host
    uwsm                    # uwsm-app, for o.launch()-wrapped keybinds
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    pamixer
    wireplumber             # wpctl
    pavucontrol
    grim
    slurp
    wl-screenrec
    libnotify               # notify-send
    jq
    gum
    fastfetch
    udiskie
    ddcutil
    imagemagick
    fuzzel                  # a launcher fallback if the shell one misbehaves
    xdg-terminal-exec
    # plain POSIX userland the scripts assume is just "there"
    coreutils
    gnused
    gawk
    gnugrep
    findutils
    procps
    util-linux
    libqalculate
  ];

  # The upstream checkout, shebang-patched for NixOS. This whole path becomes
  # $OMARCHY_PATH.
  omarchyTree = pkgs.runCommand "omarchy4-tree"
    {
      nativeBuildInputs = [ pkgs.python3 ];
    }
    ''
      cp -r ${omarchy4} $out
      chmod -R u+w $out

      # No /bin/bash or /usr/bin/python3 on NixOS. Rewrite the interpreter
      # line of every script in the tree (bin/, default/, shell/, themes/,
      # migrations/, test/, ...).
      grep -rlZ -e '^#!/bin/bash' -e '^#!/usr/bin/python3' $out 2>/dev/null | \
        while IFS= read -r -d "" f; do
          ${pkgs.gnused}/bin/sed -i \
            -e '1s@^#!/bin/bash@#!${pkgs.bash}/bin/bash@' \
            -e '1s@^#!/usr/bin/python3.*@#!${pkgs.python3}/bin/python3@' \
            "$f"
        done

      # --- macnix (MacBook10,1) local patches -----------------------------
      # Internal keyboard: this box has a custom "macnix-se" XKB layout
      # (nixos/keyboard.nix). config/hypr/input.lua ships as all-comments;
      # append a real block.
      cat >> $out/config/hypr/input.lua <<'EOF'

-- macnix: internal MacBook keyboard (see nixos/keyboard.nix).
hl.config({
  input = {
    kb_layout = "macnix-se",
    kb_model = "apple",
    kb_options = "lv3:lalt_switch,apple:alupckeys",
  },
})
EOF

      # HiDPI panel — the normal session runs eDP-1 at scale 1.5
      # (hosts/.../hyprland.nix), so match it here instead of Omarchy's
      # "auto" + GDK_SCALE=2.
      ${pkgs.gnused}/bin/sed -i \
        -e 's@^local omarchy_gdk_scale = .*@local omarchy_gdk_scale = 1@' \
        -e 's@^hl.monitor({ output = "", mode = "preferred".*@hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })\nhl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })@' \
        $out/config/hypr/monitors.lua
      # ------------------------------------------------------------------
    '';

  launcher = pkgs.writeShellScript "omarchy4-session" ''
    export OMARCHY_PATH="${omarchyTree}"
    export XDG_CONFIG_HOME="${configHome}"
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_SESSION_TYPE=wayland
    # $OMARCHY_PATH/bin first (Omarchy's own CLI), then the Nix runtime deps,
    # then whatever the login shell already had.
    export PATH="${omarchyTree}/bin:${lib.makeBinPath runtimeDeps}''${PATH:+:$PATH}"
    exec ${pkgs.hyprland}/bin/Hyprland
  '';
in
{
  home.packages = runtimeDeps;

  # ~/.config-omarchy4 — Omarchy's user config tree (personal overrides only;
  # the defaults are required out of $OMARCHY_PATH at load time). recursive
  # so directories stay real and Omarchy can drop new files / atomically
  # replace shell.json when you rearrange the bar.
  home.file.".config-omarchy4" = {
    source = "${omarchyTree}/config";
    recursive = true;
  };

  home.file.".local/bin/omarchy4-session" = {
    source = launcher;
    executable = true;
  };

  # Seed the "current theme" pointer Hyprland's bootstrap + the shell look
  # for at login:
  #   require("omarchy.current.theme.*")  resolves via  ~/.local/state/?.lua
  #   -> ~/.local/state/omarchy/current/theme/...
  # (theme-set would normally manage these; it needs pacman-era plumbing we
  # don't have, so pin tokyo-night by hand. Re-run `hm` to reset.)
  home.activation.omarchy4Theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state="${homeDirectory}/.local/state/omarchy/current"
    run mkdir -p "$state"
    run ln -sfn "${omarchyTree}/themes/tokyo-night" "$state/theme"
    run ln -sfn "${omarchyTree}/themes/tokyo-night/backgrounds/1-quattro.webp" "$state/background"
    run sh -c 'printf "%s\n" "Tokyo Night" > "'"$state"'/theme.name"'
  '';
}
