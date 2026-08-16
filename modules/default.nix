# Module registry — import this once and reference modules by name.
# Usage: let m = import ./modules; in [ m.vim m.zsh ... ]
{
  # Platform
  basic-linux = ./platform/basic-linux.nix;
  basic-mac   = ./platform/basic-mac.nix;
  imac        = ./platform/imac.nix;
  allowUnfree = ./platform/allowUnfree.nix;

  # Shells
  zsh    = ./shells/zsh.nix;
  zoxide = ./shells/zoxide.nix;

  # Editors
  vim        = ./editors/vim.nix;
  neovim     = ./editors/neovim.nix;
  neovide    = ./editors/neovide.nix;
  doom-emacs = ./editors/doom-emacs.nix;

  # Terminal emulators
  wezterm = ./terminals/wezterm.nix;
  foot    = ./terminals/foot.nix;
  ghostty = ./terminals/ghostty.nix;

  # Tmux variants
  tmux        = ./tmux/tmux.nix;
  simple-tmux = ./tmux/simple-tmux.nix;
  my-tmux     = ./tmux/my-tmux.nix;

  # Desktop / Wayland
  niri       = ./desktop/niri.nix;
  nerd-fonts = ./desktop/nerd-fonts.nix;

  # Tools
  pass              = ./tools/pass.nix;
  java              = ./tools/java.nix;
  postgresql-client = ./tools/postgresql-client.nix;
  testssl           = ./tools/testssl.nix;
  yazi              = ./tools/yazi.nix;
  podman            = ./tools/podman.nix;
  lima              = ./tools/lima.nix;
  raspberry-pi5-leds = ./tools/raspberry-pi5-leds.nix;

  # AI assistants
  claude-code = ./ai/claude-code.nix;
  copilot-cli = ./ai/copilot-cli.nix;
  ollama      = ./ai/ollama.nix;

  # Gaming
  minecraft     = ./gaming/minecraft.nix;
  esh-minecraft = ./gaming/esh-minecraft.nix;
}
