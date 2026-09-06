# EXPERIMENTAL — run the REAL upstream Omarchy 4 ("Quattro") desktop on this
# NixOS box, isolated in ~/.config-omarchy4, as its own GDM session next to
# the normal Hyprland / Niri / (omarchy-nix) Omarchy entries.
#
# See ./README.md for how it works, what works, what doesn't, and the
# version-skew notes. This file just wires the pieces together:
#
#   ./tree.nix          — upstream checkout, shebang- + macnix-patched ($OMARCHY_PATH)
#   ./nvim.nix          — the LazyVim ("omarchy-nvim") config tree
#   ./runtime-deps.nix  — nixpkgs equivalents of the tools the scripts call
#   ./launcher.nix      — ~/.local/bin/omarchy4-session (the GDM Exec)
#   ./hypr/user-keybinds.lua — keybind overlay, loaded after Omarchy's defaults
#
# GDM entry: nixos/omarchy4/ (needs `nixos-switch` once).

{ omarchy4 }:

{ pkgs, pkgsUnstable, lib, config, username, homeDirectory, ... }:

let
  configHome = "${homeDirectory}/.config-omarchy4";

  omarchyTree = import ./tree.nix { inherit pkgs omarchy4; };
  nvimConfig = import ./nvim.nix { inherit pkgs; };
  runtimeDeps = import ./runtime-deps.nix { inherit pkgs pkgsUnstable; };
  launcher = import ./launcher.nix {
    inherit pkgs pkgsUnstable lib omarchyTree runtimeDeps configHome username;
  };
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

  # Omarchy 4's LazyVim config (see ./nvim.nix). recursive so the dir stays
  # writable — lazy.nvim drops lazy-lock.json into it and plugins bootstrap
  # on first `nvim` launch. NVIM_APPNAME=omarchy-nvim (launcher) is what
  # points nvim/neovide here instead of the user's ~/.config/nvim.
  home.file.".config-omarchy4/omarchy-nvim" = {
    source = nvimConfig;
    recursive = true;
  };

  # theme.lua → a live link to whatever `omarchy theme set` last staged, so
  # LazyVim's colorscheme follows the Omarchy theme (the omarchy-lazyvim
  # package + migrations/17850*.sh do the same). home.activation.omarchy4Theme
  # below seeds this state on first run (tokyo-night → tokyonight-night).
  home.file.".config-omarchy4/omarchy-nvim/lua/plugins/theme.lua".source =
    config.lib.file.mkOutOfStoreSymlink
      "${homeDirectory}/.local/state/omarchy/current/theme/neovim.lua";

  # User keybinds overlay — loaded by hyprland.lua after Omarchy's defaults,
  # so your keybinds layer on top without modifying the upstream tree.
  # Edit ./hypr/user-keybinds.lua to customize keybindings for this session.
  home.file.".config-omarchy4/hypr/user-keybinds.lua".source =
    ./hypr/user-keybinds.lua;

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
