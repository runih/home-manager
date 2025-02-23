{ pkgs, ... }:

{
  home = {
    username = "minecraft";
    homeDirectory = "/home/minecraft";
    sessionPath = [
      "/home/minecraft/.nix-profile/bin"
    ];
    stateVersion = "25.05";
    packages = with pkgs; [
      bat
      bc
      git
      htop-vim
      jdk21
      jq
      nmon
      pstree
      tmux
      tree
      unzip
    ];
  };
  programs = {
    home-manager.enable = true;
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "sorin";
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      defaultKeymap = "viins";
      shellAliases = {
        cd = "z";
        cdi = "zi";
      };
    };
    vim = {
      enable = true;
    };
  };
}
