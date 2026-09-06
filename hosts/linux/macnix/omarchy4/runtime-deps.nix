# Tools the bin/omarchy-* scripts and the Hyprland/Quickshell configs call
# that DO have a nixpkgs equivalent. Arch-only ones (pacman, yay, snapper,
# limine, mise-bin, asdcontrol, expac, ...) are deliberately absent — the
# scripts that need them will fail, and that's covered in ./README.md.
#
# Consumed by ./default.nix (home.packages) and ./launcher.nix (PATH).

{ pkgs, pkgsUnstable }:

(with pkgsUnstable; [
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
  # LazyVim ("omarchy-nvim") first-run bootstrap + day-to-day deps — see
  # ./nvim.nix. lazy.nvim clones plugins with git; nvim-treesitter compiles
  # parsers with `cc` (gcc) + make; LazyVim's pickers want ripgrep + fd,
  # <leader>gg wants lazygit, mason/parsers occasionally unzip.
  # (node for LSP/mason comes from the profile — home.nix's nodejs_22.)
  git
  gcc
  gnumake
  tree-sitter
  ripgrep
  fd
  lazygit
  unzip
])
