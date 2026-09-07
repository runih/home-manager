# The upstream Omarchy 4 checkout, shebang-patched for NixOS plus a set of
# macnix-local patches. This whole path becomes $OMARCHY_PATH (see
# ./launcher.nix). See ./README.md for the rationale behind each patch.
#
# The runCommand body is kept byte-for-byte as it was in the old
# omarchy4-session.nix so the `omarchy4-tree` store path does not move.

{ pkgs, omarchy4 }:

pkgs.runCommand "omarchy4-tree" { }
    ''
      cp -r ${omarchy4} $out
      chmod -R u+w $out

      # macnix: NixOS can't apply Omarchy's updates — no pacman, and
      # $OMARCHY_PATH is a read-only store copy with no git upstream. Stub
      # omarchy-update-available to always report "up to date" so the bar's
      # SystemUpdate widget stays hidden and omarchy-update-status clears.
      # Done here, before the shebang pass below, so the #!/bin/bash gets
      # rewritten with the rest.
      cat > $out/bin/omarchy-update-available <<'EOF'
#!/bin/bash
# Overridden for macnix — see hosts/linux/macnix/omarchy4/README.md.
echo "Omarchy is up to date"
exit 1
EOF

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

-- macnix: internal MacBook keyboard (see nixos/keyboard.nix) + natural
-- scrolling on the touchpad (matches the normal Hyprland session,
-- hosts/linux/macnix/hyprland.nix). Loaded after Omarchy's defaults, so
-- this wins.
hl.config({
  input = {
    kb_layout = "macnix-se",
    kb_model = "apple",
    kb_options = "lv3:lalt_switch,apple:alupckeys",
    touchpad = {
      natural_scroll = true,
    },
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
      # Explicit two-head layout: HP ENVY 34 (DP-1, 3440x1440 @ scale 1) is
      # the primary at 0x0; the MacBook panel (eDP-1, scale 1.5 -> 1536x960
      # logical) sits to its right, bottom-aligned (y = 1440 - 960 = 480) so
      # the bottom edges line up the way the hardware sits on the desk.
      cat >> $out/config/hypr/monitors.lua <<'EOF'

hl.monitor({ output = "DP-1", mode = "3440x1440@60", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "3440x480", scale = 1.5 })
EOF

      # Hyprland Lua API skew: 0.55.4's `hl.get_active_monitor()` handle had
      # no `.reserved` field, so qconsole.lua:71 errored with "attempt to
      # index a nil value (local 'reserved')" and tripped the config-error
      # overlay. 0.56.2 (pkgsUnstable) has the field, so this is now a
      # harmless no-op — keep it as a guard, drop it if the tree ever moves
      # on and the sed pattern stops matching.
      ${pkgs.gnused}/bin/sed -i \
        's/^  local reserved = monitor\.reserved$/  local reserved = monitor.reserved or { top = 0, bottom = 0 }/' \
        $out/default/hypr/qconsole.lua

      # No "Update System" nag. omarchy-provision-first-run (autostart on
      # every login) runs install/user/first-run/wifi.sh, whose
      # announce_network sends a critical "Click to update the system"
      # toast once the network is up — pointless here, `omarchy-update`
      # can't do anything on NixOS. Neuter just that call (the Wi-Fi setup
      # prompt in the same script is left alone).
      ${pkgs.gnused}/bin/sed -i \
        's/^  notify_update$/  : # macnix: no omarchy-update on NixOS/' \
        $out/install/user/first-run/wifi.sh

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

      # Default editor → neovide. omarchy-launch-editor is what every "open
      # this in an editor" path funnels through (the SUPER+SHIFT+N bind, the
      # menu's "edit config" actions, omarchy-clipboard-open, the branding
      # editors). Two fixes:
      #   - default it to `neovide` instead of `nvim` (its `omarchy default
      #     editor` menu list — code/zed/helix/vim/nvim/… — has no neovide,
      #     and ~/.local/state/omarchy/defaults/editor is unset here). The
      #     menu can still override this at runtime.
      #   - drop the `uwsm-app` wrapper on the GUI-editor branch — this
      #     session isn't uwsm-managed, so `uwsm-app -- neovide` never fires
      #     (same reason as the terminal / logout patches above).
      ${pkgs.gnused}/bin/sed -i \
        -e 's#editor="nvim"#editor="neovide"#g' \
        -e 's#uwsm-app -- ##' \
        $out/bin/omarchy-launch-editor

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
    ''
