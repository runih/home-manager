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

-- (Editor: Super+Shift+N and every "edit config" flow go through
-- omarchy-launch-editor, which the runCommand patches to launch
-- neovide directly — no keybind override needed here.)
