# Home-manager packages for macnix. Merges:
# - a plain nixpkgs package list (formerly packages-user.nix)
# - packages that don't fit a shared module in modules/default.nix,
#   either pulled from nixpkgs-unstable (see CLAUDE.md's "Unstable
#   packages" section) or a one-off flake input (zen-browser)
#
# Curried: flake.nix partially applies the outer args (zen-browser, lib,
# enableOmarchy) before this is used as a home-manager module.
{ zen-browser, lib, enableOmarchy }:
{ pkgs, pkgsUnstable, ... }:

{
  home.packages = with pkgs; [
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
    wdisplays       # Wayland display configuration GUI
    discord         # Discord chat client
    slack           # Slack chat client
  ] ++ [
    zen-browser.packages."x86_64-linux".default
    pkgsUnstable.claude-code
    pkgsUnstable.ollama
  ]
  # `gh` from unstable is dropped when omarchy is on — its git.nix
  # enables `programs.gh` (stable), and two gh's collide in the profile.
  ++ lib.optional (!enableOmarchy) pkgsUnstable.gh;
}
