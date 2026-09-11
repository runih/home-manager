# Omarchy 4 ("Quattro") session — macnix

**EXPERIMENTAL.** Runs the *real* upstream Omarchy 4 desktop
([`github:omacom/omarchy`](https://github.com/omacom/omarchy)) on this NixOS box,
isolated in `~/.config-omarchy4`, as its own GDM session next to the normal
Hyprland / Niri / (omarchy-nix) "Omarchy" entries.

Toggled by `enableOmarchy4Session` in `../flake.nix` (independent of
`enableOmarchy` / `enableOmarchySession`, which use omarchy-nix's older
Omarchy-3-era stack). The GDM entry is registered system-side in
`../nixos/omarchy4/` and needs `nixos-switch` once.

## Why this is separate from `../omarchy-session.nix`

`../omarchy-session.nix` vendors *omarchy-nix*'s generated dotfiles — an
Omarchy-3-era stack (waybar + walker + mako + hyprlock). Omarchy 4 threw all of
that out for one long-running Quickshell process. omarchy-nix has not been ported
to it and is unmaintained, so this module points at upstream directly instead.

## How it works

- **The upstream repo IS the runtime.** There is no "generated tree": `tree.nix`
  takes the checkout, patches its 700+ `#!/bin/bash` / `#!/usr/bin/python3`
  shebangs (no `/bin/bash` or `/usr/bin/python3` on NixOS) plus a handful of
  macnix-local fixes, and the result becomes `$OMARCHY_PATH`.
- **`launcher.nix`** → `~/.local/bin/omarchy4-session` (fixed path so the system
  `.desktop` in `../nixos/omarchy4/` can point at it). Exports `OMARCHY_PATH` +
  `XDG_CONFIG_HOME=~/.config-omarchy4` + `NVIM_APPNAME=omarchy-nvim`, fixes
  `PATH` (setuid wrappers first, then `$OMARCHY_PATH/bin`, then the Nix runtime
  deps), and execs `start-hyprland`.
- Hyprland reads `~/.config-omarchy4/hypr/hyprland.lua`, which `dofile`s
  `$OMARCHY_PATH/default/hypr/bootstrap.lua` and pulls in Omarchy's Lua
  defaults; its autostart launches `omarchy-launch-shell` → Quickshell.
- The normal Hyprland session (`~/.config/hypr`, `../hyprland.nix`) is untouched
  — different `XDG_CONFIG_HOME`, different config tree.

## Files

| file | what |
|---|---|
| `default.nix` | wires the pieces, emits `home.packages` / `home.file` / the first-run theme seed |
| `tree.nix` | the shebang- + macnix-patched upstream checkout (`$OMARCHY_PATH`) |
| `nvim.nix` | the LazyVim ("omarchy-nvim") config tree, assembled from `LazyVim/starter` + `omacom/omarchy-lazyvim` |
| `runtime-deps.nix` | nixpkgs equivalents of the tools the `omarchy-*` scripts + Hyprland/Quickshell call |
| `launcher.nix` | `~/.local/bin/omarchy4-session` |
| `hypr/user-keybinds.lua` | keybind overlay, loaded after Omarchy's defaults (Super+Return → ghostty, vim-motion window nav, Super+Ctrl+F maximize) |

## What works (best case — expect to iterate on-device)

The compositor, the Quickshell bar / menu / launcher / lock, and the theming
that ships inside the repo (tokyo-night is the default, seeded on first run).

`tree.nix` also patches the Quickshell `menu` / `clipboard` / `emojis` key
handlers to add fzf-style vim-motion navigation (Ctrl+h/j/k/l) next to the
arrow keys — bare h/j/k/l stay filter input. The patch asserts its anchors
and fails the build if a Quickshell refactor moves them.

## Neovim

The `omarchy-nvim` / `omarchy-lazyvim` Arch package has no Nix build, so
`nvim.nix` assembles the config half (LazyVim starter + omarchy's thin overlay)
and it's isolated via `NVIM_APPNAME=omarchy-nvim` — every `nvim`/`neovide` in
the session uses `~/.config-omarchy4/omarchy-nvim` + `~/.local/{share,state}/omarchy-nvim`
+ `~/.cache/omarchy-nvim`. `lazy.nvim` bootstraps the plugins on the first
launch (needs network, ~1–2 min). The user's real `~/.config/nvim` is untouched.

`~/.config-omarchy4/omarchy-nvim` is **seeded once** from the Nix-built tree
(`home.activation.omarchy4Nvim`), then it's plain writable files you own and
edit like any LazyVim config. Later changes to `nvim.nix` do **not** reach an
existing copy — delete a file (or the whole dir) and re-run `hm` to re-seed.
`lua/plugins/theme.lua` stays a symlink that follows `omarchy theme set`.

## What does not

- Every menu action that shells out to pacman / yay / snapper / limine /
  `systemctl` as root — install, update, rollback, most of the "system" menu.
  Those are Arch + Omarchy-ISO assumptions with no equivalent here; do that
  stuff through this repo's Nix config instead.
- `o.launch()` app keybinds wrap the command in `uwsm-app`; this launcher starts
  Hyprland directly, not under uwsm, so those may not fire. Switch the launcher
  to `uwsm start` if it matters. (The terminal / editor / logout paths are
  patched around this in `tree.nix`.)
- First-run / provisioning hooks, mise, voxtype, fingerprint, etc.
- **Updates.** `omarchy-update` can't do anything here (no pacman, `$OMARCHY_PATH`
  is a read-only store copy). `tree.nix` stubs `omarchy-update-available` to
  always say "up to date" (hides the bar's SystemUpdate widget) and neuters the
  "Click to update the system" first-run toast in `install/user/first-run/wifi.sh`.
  Update by bumping the `omarchy4` input in the root flake + `hm`.

## Version skew (the real risk)

Hyprland comes from `nixpkgs-unstable` now (`pkgsUnstable`, currently 0.56.2 —
see `../nixos/programs.nix` and `../hyprland.nix`); Quickshell is still
nixos-26.05's 0.3.0. Omarchy 4 tracks whatever Arch shipped at its release.
Hyprland's Lua config API and Quickshell's QML API both move fast — if the bar
won't render or Hyprland rejects the config, that's almost certainly why. Bump
the `omarchy4` input / try newer pkgs and re-test.
