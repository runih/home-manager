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
      PG_PASS = "${homeDirectory}/.pgpass";
      PG_NETWORK = "docker_my_network";
      PG_HISTORY = "${homeDirectory}/.psql_history";
      FZF_DEFAULT_OPTS = "--bind=ctrl-j:down,ctrl-k:up";
    };
    # Add custom paths to the session's PATH environment variable
    sessionPath = [
      "${homeDirectory}/.nix-profile/bin"
      "${homeDirectory}/bin"
      "${homeDirectory}/.local/bin"
    ];

    # Specify the state version for compatibility
    stateVersion = "26.05";

    # List of packages to be installed for the user
    packages = with pkgs; [
      bat             # A cat clone with syntax highlighting
      bc              # An arbitrary precision calculator language
      blueman         # Bluetooth manager
      bluetuith       # Bluetooth TUI
      btop            # Resource monitor
      dnsutils        # Utilities for querying DNS servers
      fastfetch       # A fast system information tool
      fd              # A simple, fast and user-friendly alternative to find
      file            # Determine file types
      gcc             # GNU Compiler Collection
      git             # Version control system
      gnumake         # Build automation tool
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
      rustup          # Rust toolchain installer
      superfile       # (Assumed custom package, no description available)
      tmux            # Terminal multiplexer
      tree            # Display directories as trees
      unzip           # Extract ZIP archives
      usbutils        # Utilities for USB devices
      virtualenv      # Tool to create isolated Python environments
      w3m             # Text-based web browser
      wget            # Command-line utility for downloading files
    ];

  };

  programs = {
    # Enable home-manager for managing user configurations
    home-manager.enable = true;

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
      useTheme = "blue-owl";             # Set the theme to "sorin"
    };

    # Configuration for the vim program (text editor)
    vim = {
      enable = true;                  # Enable vim
    };
  };
}
