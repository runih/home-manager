{ pkgs, username, homeDirectory, ... }:

{
  home = {
    # Define the username for the home configuration
    username = "${username}";

    # Specify the home directory path
    homeDirectory = "${homeDirectory}";

    # Set the default editor for the session
    sessionVariables = {
      EDITOR = "nvim";
      PG_NETWORK = "docker_my_network";
    };
    # Add custom paths to the session's PATH environment variable
    sessionPath = [
      "${homeDirectory}/.nix-profile/bin"
    ];

    # Specify the state version for compatibility
    stateVersion = "25.05";

    # List of packages to be installed for the user
    packages = with pkgs; [
      bat             # A cat clone with syntax highlighting
      bc              # An arbitrary precision calculator language
      fd              # A simple, fast and user-friendly alternative to find
      file            # Determine file types
      git             # Version control system
      htop-vim        # Interactive process viewer with vim keybindings
      btop            # Resource monitor
      lynx            # Text-based web browser
      pstree          # Display a tree of processes
      ripgrep         # A fast search tool
      superfile       # (Assumed custom package, no description available)
      tmux            # Terminal multiplexer
      tree            # Display directories as trees
      unzip           # Extract ZIP archives
      wget            # Command-line utility for downloading files
      nodejs_22       # JavaScript runtime built on Chrome's V8 engine
      gnumake         # Build automation tool
      gcc             # GNU Compiler Collection
      lazygit         # Simple terminal UI for git commands
      rustup          # Rust toolchain installer
      w3m             # Text-based web browser
      pciutils        # Utilities for listing PCI devices
      blueman         # Bluetooth manager
      bluetuith       # Bluetooth TUI
      teams-for-linux # Unofficial Microsoft Teams client for Linux
    ];
  };

  programs = {
    # Enable home-manager for managing user configurations
    home-manager.enable = true;

    neovim.enable = true;


    # Configuration for the eza program (modern ls replacement)
    eza = {
      enable = true;                  # Enable eza
      enableZshIntegration = true;    # Enable Zsh integration
      git = true;                     # Enable Git support
      icons = "auto";                 # Automatically enable icons
    };

    # Configuration for the fzf program (fuzzy finder)
    fzf = {
      enable = true;                  # Enable fzf
      enableZshIntegration = true;    # Enable Zsh integration
    };

    # Configuration for the oh-my-posh program (prompt theme engine)
    oh-my-posh = {
      enable = true;                  # Enable oh-my-posh
      enableZshIntegration = true;    # Enable Zsh integration
      useTheme = "craver";             # Set the theme to "sorin"
    };

    # Configuration for the vim program (text editor)
    vim = {
      enable = true;                  # Enable vim
    };
  };
}
