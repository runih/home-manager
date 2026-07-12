{ pkgs, ... }:

{
  home = {
    # Define the username for the home configuration
    username = "runihadmin";

    # Specify the home directory path (matches $HOME/passwd; /volume1/homes/...
    # is a Synology-provided alias to the same directory, but tools that do a
    # literal string match against $HOME, like `claude doctor`'s PATH check,
    # don't recognize it as equivalent).
    homeDirectory = "/var/services/homes/runihadmin";

    # Set the default editor for the session
    sessionVariables = {
      EDITOR = "nvim";
      # DSM's system terminfo db doesn't ship a tmux-256color entry, which
      # breaks the system `clear`/`tput`/etc. inside tmux. Point at nix's
      # ncurses terminfo so those tools can resolve it.
      TERMINFO_DIRS = "${pkgs.ncurses}/share/terminfo";
    };

    # Add custom paths to the session's PATH environment variable
    sessionPath = [
      "/var/services/homes/runihadmin/.nix-profile/bin"
      "/var/services/homes/runihadmin/.local/bin"
    ];

    # Specify the state version for compatibility
    stateVersion = "25.05";

    # List of packages to be installed for the user
    packages = with pkgs; [
      bat          # A cat clone with syntax highlighting
      bc           # An arbitrary precision calculator language
      file         # Determine file types
      git          # Version control system
      htop-vim     # Interactive process viewer with vim keybindings
      lynx         # Text-based web browser
      pstree       # Display a tree of processes
      superfile    # (Assumed custom package, no description available)
      tmux         # Terminal multiplexer
      tree         # Display directories as trees
      unzip        # Extract ZIP archives
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
      useTheme = "sorin";             # Set the theme to "sorin"
    };
  };

  # DSM's sshd negotiates a bare "xterm" TERM (only 8 colors per terminfo)
  # instead of forwarding the client's real "xterm-256color"/"tmux-256color".
  # Upgrade it as early as possible (.zshenv, before compinit/oh-my-posh/eza
  # ever read $TERM) so color-aware tools see proper 256-color support.
  programs.zsh.envExtra = ''
    if [[ "$TERM" == "xterm" ]]; then
      export TERM="xterm-256color"
    fi
  '';
}
