{  pkgs, username, homeDirectory, ... }:

{
  # Configuration for the home environment
  home = {
    # Username of the user
    username = "${username}";

    # Path to the user's home directory
    homeDirectory = "${homeDirectory}";

    # Paths to include in the session's PATH environment variable
    sessionPath = [
      "${homeDirectory}/.nix-profile/bin"
      "${homeDirectory}/bin"
    ];

    # State version for compatibility with Home Manager
    stateVersion = "25.05";

    # List of packages to install in the user's environment
    packages = with pkgs; [
			bat          	# A cat clone with syntax highlighting
			bc           	# An arbitrary precision calculator language
			binutils     	# GNU binary utilities
			btop         	# A resource monitor
			dig          	# DNS lookup utility
			fd           	# A simple, fast and user-friendly alternative to find
			gimp         	# GNU Image Manipulation Program
			git          	# Version control system
			gnupg1       	# GNU Privacy Guard (version 1)
			go           	# Go programming language
			htop-vim     	# Interactive process viewer with vim keybindings
			lazygit      	# Simple terminal UI for git commands
			libjpeg      	# JPEG image library
			neovim       	# Modern Vim-based text editor
			ninja        	# Build system
			nodejs_22    	# Node.js runtime (version 22)
			nurl         	# URL manipulation library
			pstree       	# Display a tree of processes
			ripgrep      	# A fast search tool
			rustup       	# Rust toolchain installer
			tree         	# Display directories as trees
			unzip        	# Extract ZIP archives
			utm		  		  # Virtual machine manager for macOS
			w3m          	# Text-based web browser
			wget         	# Command-line utility for downloading files
    ];

    # Configuration for user-specific files
    file = {
      # Input configuration for readline
      ".inputrc".text = ''
        set editing-mode vi
      '';

      # Configuration for PostgreSQL client
      ".psqlrc".text = ''
        \set QUIET 1
        \pset linestyle unicode
        \pset border 2
        \set COMP_KEYWORD_CASE upper
        \set PSQL_EDITOR "/usr/bin/vim"
        \pset pager off
        \timing
        \pset format wrapped
        \pset null '<null>'
      '';
    };

    # Environment variables for the session
    sessionVariables = {
      EDITOR = "nvim";                            # Set Neovim as the default editor
      TERM = "xterm-256color";                    # Set terminal type for color support
      PG_PASS = "${homeDirectory}/.pgpass";       # Path to PostgreSQL password file
    };
  };

  # Configuration for additional programs
  programs = {
    home-manager.enable = true;  # Enable Home Manager

    # Configuration for zoxide, a smarter cd command
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Configuration for eza, a modern ls replacement
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;                # Enable git integration
      icons = "auto";            # Automatically enable icons
    };

    # Configuration for fzf, a fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Configuration for oh-my-posh, a prompt theme engine
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "the-unnamed";  # Set the theme to "the-unnamed"
    };
  };
}
