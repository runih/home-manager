{ pkgs }:

# User package list for macnix (home.packages). Split out of home.nix to
# keep that file focused on core `home.*` settings. Not to be confused
# with ./packages.nix, which builds the home-manager module list itself
# (imports, zen-browser, allowUnfree, etc.) and is passed to mkHome as its
# own module.
with pkgs; [
  aichat          # Terminal client for GPT-4, Gemini, Ollama and other LLMs
  alsa-utils      # Utilities for ALSA sound system
  atlauncher      # Minecraft launcher
  bash            # GNU Bourne-Again Shell
  bat             # A cat clone with syntax highlighting
  bc              # An arbitrary precision calculator language
  blueman         # Bluetooth manager
  bluetuith       # Bluetooth TUI
  btop            # Resource monitor
  dnsutils        # Utilities for querying DNS servers
  fd              # A simple, fast and user-friendly alternative to find
  file            # Determine file types
  gcc             # GNU Compiler Collection
  git             # Version control system
  github-copilot-cli # GitHub Copilot CLI
  jq              # Command-line JSON processor
  gimp            # GNU Image Manipulation Program
  gnumake         # Build automation tool
  libreoffice     # Office productivity suite
  neovim
  go             # Go programming language
  htop-vim        # Interactive process viewer with vim keybindings
  lazygit         # Simple terminal UI for git commands
  lynx            # Text-based web browser
  minio-client    # Client for MinIO and Amazon S3 compatible cloud storage
  net-tools       # Network configuration tools
  nodejs_22       # JavaScript runtime built on Chrome's V8 engine
  pciutils        # Utilities for listing PCI devices
  pstree          # Display a tree of processes
  ripgrep         # A fast search tool
  rofi-network-manager # Rofi-based wifi/ethernet connection picker
  rustup          # Rust toolchain installer
  superfile       # (Assumed custom package, no description available)
  teams-for-linux # Unofficial Microsoft Teams client for Linux
  tmux            # Terminal multiplexer
  tree            # Display directories as trees
  unzip           # Extract ZIP archives
  usbutils        # Utilities for USB devices
  virtualenv      # Tool to create isolated Python environments
  w3m             # Text-based web browser
  wget            # Command-line utility for downloading files
  wl-clipboard    # Wayland clipboard utilities (wl-copy, wl-paste)
  awww            # Wallpaper daemon for Wayland (swww)
  brightnessctl   # Screen/keyboard backlight control
  hyprlock        # Lock screen for Hyprland
  wlogout         # Wayland logout screen
  wofi            # Application launcher for Wayland
]
