{ ... }:

{
  programs = {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    #mtr.enable = true;
    nix-ld.enable = true;
    #gnupg.agent = {
    #  enable = true;
    #  pinentryPackage = pkgs.pinentry-curses;
    #  enableSSHSupport = true;
    #};
    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };

    # enable zsh and oh my zsh
    zsh= {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "juanghurtado";
        plugins = [
          "colored-man-pages"
          "colorize"
          "git"
          "pass"
          "vi-mode"
          "vim-interaction"
        ];
      };
    };
  };
}
