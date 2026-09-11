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

-- Vim-motion window navigation, to match the normal Hyprland session
-- (hosts/linux/macnix/hyprland.nix): Super+h/j/k/l moves focus,
-- Super+Shift+h/j/k/l moves the window. Omarchy's arrow-key focus
-- bindings are left in place alongside these.
--
-- The three Omarchy defaults that own these letters are relocated to
-- Super+Shift+Ctrl+<letter> rather than dropped (Super+Ctrl+<letter> is
-- already taken on all three: Hardware menu / Herdr keybindings / Lock):
--   Super+J  Toggle window split       -> Super+Shift+Ctrl+J
--   Super+K  Keybindings cheat sheet   -> Super+Shift+Ctrl+K
--   Super+L  Toggle workspace layout   -> Super+Shift+Ctrl+L
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + SHIFT + CTRL + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + SHIFT + CTRL + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + SHIFT + CTRL + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

o.bind("SUPER + H", "Focus left",  hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus down",  hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up",    hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))

o.bind("SUPER + SHIFT + H", "Move window left",  hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Move window down",  hl.dsp.window.move({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Move window up",    hl.dsp.window.move({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))

-- Super+Ctrl+F: maximize the window to fill the monitor minus the bar
-- (a hard maximize, not a per-app fullscreen signal). Omarchy binds this
-- to its "Tiled full screen" toggle by default; that toggle moves to
-- Super+Shift+Ctrl+F. (Super+Alt+F stays as Omarchy's identical "Full
-- width" binding.)
hl.unbind("SUPER + CTRL + F")
o.bind("SUPER + CTRL + F", "Maximize (within bar)", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + SHIFT + CTRL + F", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")
