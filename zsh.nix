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
    };
    initContent = ''
    bindkey -v
    bindkey -M viins '^E' end-of-line
    '';
  };
}
