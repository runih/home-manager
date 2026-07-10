{ ... }:
{
  programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      defaultKeymap = "viins";
      shellAliases = {
        cd = "z";
        cdi = "zi";
        hm = "home-manager switch --flake ~/.config/home-manager#nas";
      };
    };
}
