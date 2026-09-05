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
# VERSION SKEW (the real risk): Hyprland comes from nixpkgs-unstable now
# (pkgsUnstable, currently 0.56.2 — see hosts/linux/macnix/nixos/programs.nix
# and hyprland.nix); Quickshell is still nixos-26.05's 0.3.0. Omarchy 4
# tracks whatever Arch shipped at its release. Hyprland's Lua config API and
# Quickshell's QML API both move fast — if the bar won't render or Hyprland
# rejects the config, that's almost certainly why. Bump the `omarchy4` input
# / try newer pkgs and re-test.

{ omarchy4 }:

{ pkgs, pkgsUnstable, lib, config, username, homeDirectory, ... }:

let
  configHome = "${homeDirectory}/.config-omarchy4";

  # Tools the bin/omarchy-* scripts and the Hyprland/Quickshell configs call
  # that DO have a nixpkgs equivalent. Arch-only ones (pacman, yay, snapper,
  # limine, mise-bin, asdcontrol, expac, ...) are deliberately absent — the
  # scripts that need them will fail, and that's covered above.
  runtimeDeps = (with pkgsUnstable; [
    hyprland                # hyprctl, and the compositor the launcher execs
    hyprland-qtutils        # hyprland-dialog / hyprland-toast used by scripts
    hypridle
    hyprsunset
    hyprpicker
  ]) ++ (with pkgs; [
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
  ]);

  # The upstream checkout, shebang-patched for NixOS. This whole path becomes
  # $OMARCHY_PATH.
  omarchyTree = pkgs.runCommand "omarchy4-tree" { }
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

      # Omarchy's Hyprland bootstrap hardcodes ~/.config in the Lua module
      # search path (package.path) and ignores XDG_CONFIG_HOME — which this
      # session points at ~/.config-omarchy4. Without this, the require()s
      # at hyprland.lua:19+ (`require("hypr.monitors")` &c.) resolve against
      # ~/.config/hypr (the NORMAL session's tree) and error out. Append a
      # fixup that also searches $XDG_CONFIG_HOME, ahead of the hardcode.
      cat >> $out/default/hypr/bootstrap.lua <<'EOF'

-- macnix: also search $XDG_CONFIG_HOME (Omarchy hardcodes ~/.config above).
do
  local xdg = os.getenv("XDG_CONFIG_HOME")
  if xdg and xdg ~= "" then
    package.path = xdg .. "/?.lua;" .. package.path
  end
end
EOF

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
      # (hosts/.../hyprland.nix); match it, and drop Omarchy's GDK_SCALE=2
      # (its "leave XWayland unscaled" trick assumes an integer monitor
      # scale). Pure append + one sed — no line surgery that can break Lua.
      ${pkgs.gnused}/bin/sed -i \
        's/^local omarchy_gdk_scale = .*/local omarchy_gdk_scale = 1/' \
        $out/config/hypr/monitors.lua
      printf '\nhl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })\n' \
        >> $out/config/hypr/monitors.lua

      # Hyprland Lua API skew: 0.55.4's `hl.get_active_monitor()` handle had
      # no `.reserved` field, so qconsole.lua:71 errored with "attempt to
      # index a nil value (local 'reserved')" and tripped the config-error
      # overlay. 0.56.2 (pkgsUnstable) has the field, so this is now a
      # harmless no-op — keep it as a guard, drop it if the tree ever moves
      # on and the sed pattern stops matching.
      ${pkgs.gnused}/bin/sed -i \
        's/^  local reserved = monitor\.reserved$/  local reserved = monitor.reserved or { top = 0, bottom = 0 }/' \
        $out/default/hypr/qconsole.lua

      # The power/system menu's "Log out" runs `uwsm stop`, but this
      # launcher starts Hyprland via start-hyprland, not uwsm — so logout
      # silently does nothing. Swap in a compositor exit. Under Hyprland
      # 0.56's Lua config, `hyprctl dispatch` evaluates its argument as Lua
      # (the old bare `dispatch exit` / `dispatch <name> <args>` forms are
      # gone — they now error with "expected a dispatcher"), so it must be
      # the `hl.dsp.exit()` call form. Matches Hyprland 0.56's own default
      # Super+M bind. start-hyprland sees the clean exit and ends the
      # session. (reboot/shutdown use systemctl and already work.)
      ${pkgs.gnused}/bin/sed -i \
        "s/uwsm stop/hyprctl dispatch 'hl.dsp.exit()'/" \
        $out/bin/omarchy-system-logout

      # $OMARCHY_PATH/themes/* is in the read-only Nix store, so
      # omarchy-theme-set's `cp -r "$OMARCHY_THEMES_PATH/$THEME_NAME/"*`
      # produces mode-0555 copies (backgrounds/ and its files above all).
      # The *next* theme switch then can't `rm -rf "$CURRENT_THEME_PATH"`
      # — rm can't unlink entries inside a non-writable directory — so
      # `mv "$NEXT_THEME_PATH" "$CURRENT_THEME_PATH"` finds the old dir
      # still there, silently fails, and
      # ~/.local/state/omarchy/current/theme is left with no
      # colors.toml / hyprland.lua / shell.toml: the whole session loses
      # its theme (Quickshell + Hyprland come up unthemed / broken). On
      # Arch $OMARCHY_PATH is a writable git checkout so this never bites.
      # Force the staging trees writable right before each rm.
      ${pkgs.gnused}/bin/sed -i \
        -e 's@^rm -rf "$NEXT_THEME_PATH"@chmod -R u+w "$NEXT_THEME_PATH" 2>/dev/null || true; &@' \
        -e 's@^rm -rf "$CURRENT_THEME_PATH"@chmod -R u+w "$CURRENT_THEME_PATH" 2>/dev/null || true; &@' \
        $out/bin/omarchy-theme-set

      # --- macnix: EXPERIMENTAL spacer-pane "gap" hack for tmux -----------
      # tmux draws every pane border as one continuous rule the full length
      # of the shared edge (pane-border-lines) — there's no built-in option
      # for a real blank gap between panes the way a tiling compositor's
      # gaps_in works. This fakes one: each split also carves off a 1-cell
      # pane that just runs `sleep infinity` (no shell, nothing to
      # accidentally type into) and inserts it *between* the two real
      # panes, so you get an actual blank cell instead of a drawn rule.
      # Appending redefines the same keys tmux.conf already binds above —
      # tmux uses the last `bind` for a given key/table, so this wins.
      #
      # Rough edges (proof of concept, not a polished feature):
      #   - killing a real pane next to a spacer leaves the spacer
      #     orphaned; `prefix k`/`prefix K` (kill-window/-session) clear a
      #     whole window/session at once, killing one pane at a time does
      #     not.
      #   - the spacer is a real pane: pane-cycling binds (C-M-arrow) and
      #     `prefix q` (show pane numbers) can land on / label it.
      #   - splitting again inside an already-gapped layout stacks another
      #     spacer; layouts get spacer-dense fast.
      # Revert by deleting this block.
      cat >> $out/config/tmux/tmux.conf <<'EOF'

# macnix: spacer-pane gap hack (see omarchy4-session.nix)
bind -N "Split pane vertically (gapped)" -n M-Enter split-window -v -c "#{pane_current_path}" \; split-window -v -b -d -l 1 'exec sleep infinity'
bind -N "Split pane horizontally (gapped)" -n M-S-Enter split-window -h -c "#{pane_current_path}" \; split-window -h -b -d -l 1 'exec sleep infinity'
bind -N "Split pane vertically (gapped)" h split-window -v -c "#{pane_current_path}" \; split-window -v -b -d -l 1 'exec sleep infinity'
bind -N "Split pane horizontally (gapped)" v split-window -h -c "#{pane_current_path}" \; split-window -h -b -d -l 1 'exec sleep infinity'
EOF
      # ------------------------------------------------------------------

      # Load user keybinds at the END of hyprland.lua (safest place, after
      # all defaults are loaded). This allows ~/.config-omarchy4/hypr/user-keybinds.lua
      # to override/extend Omarchy's default keybinds.
      cat >> $out/config/hypr/hyprland.lua <<'EOF'

-- Load user keybinds overlay (if it exists)
local user_keybinds = os.getenv("XDG_CONFIG_HOME") .. "/hypr/user-keybinds.lua"
local f = io.open(user_keybinds, "r")
if f then f:close(); dofile(user_keybinds) end
EOF
      # ------------------------------------------------------------------
    '';

  launcher = pkgs.writeShellScript "omarchy4-session" ''
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

  # User keybinds overlay — loaded by hyprland.lua after Omarchy's defaults,
  # so your keybinds layer on top without modifying the upstream tree.
  # Edit this file to customize keybindings for the Omarchy 4 session.
  home.file.".config-omarchy4/hypr/user-keybinds.lua" = {
    text = ''
      -- User keybinds overlay for Omarchy 4. Loaded (via a dofile hook the
      -- runCommand appends to config/hypr/hyprland.lua) AFTER Omarchy's
      -- defaults, so these layer on top. `o` and `hl` are globals by this
      -- point: use o.bind(keys, description, command) — the Omarchy helper
      -- from default/hypr/helpers.lua — not raw hl.bind. There is no
      -- `mainMod` variable in Omarchy's Lua config; write "SUPER" out.

      -- Terminal launcher (Super+Return). Omarchy already binds this to its
      -- configured default terminal ({ omarchy = "terminal" }); unbind first,
      -- then point it straight at ghostty. (Or drop this and just run
      -- `omarchy-default-terminal ghostty` once — menu: Setup > Default Terminal.)
      hl.unbind("SUPER + RETURN")
      o.bind("SUPER + RETURN", "Terminal", "ghostty")
    '';
  };

  home.file.".local/bin/omarchy4-session" = {
    source = launcher;
    executable = true;
  };

  # XDG_CONFIG_HOME=~/.config-omarchy4 redirects every XDG-respecting tool,
  # not just Hyprland/Omarchy. Pass the ones that must NOT be isolated
  # straight through to the real ~/.config. `nix` is the critical one (its
  # nix.conf holds experimental-features — without it `hm` breaks inside
  # the session); add more here if other tools misbehave.
  home.file.".config-omarchy4/nix".source =
    config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.config/nix";

  # Seed an initial "current theme" ONLY on first run — the shell + Hyprland
  # both read ~/.local/state/omarchy/current/{theme,background,theme.name} at
  # login, and `require("omarchy.current.theme.*")` resolves theme/ via
  # ~/.local/state/?.lua. After that, `omarchy-theme-set` (the menu) owns
  # this state — so bail if it already exists rather than clobbering it
  # (an unconditional `ln -sfn` into what is by then a real directory just
  # nests a link inside it). `omarchy theme set <name>` to change it, or
  # wipe ~/.local/state/omarchy/current to re-seed.
  home.activation.omarchy4Theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state="${homeDirectory}/.local/state/omarchy/current"
    if [ ! -e "$state/theme" ]; then
      run mkdir -p "$state"
      run ln -s "${omarchyTree}/themes/tokyo-night" "$state/theme"
      run ln -s "${omarchyTree}/themes/tokyo-night/backgrounds/1-quattro.webp" "$state/background"
      run sh -c 'printf "%s\n" "Tokyo Night" > "'"$state"'/theme.name"'
    fi
  '';
}
