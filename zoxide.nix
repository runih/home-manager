{ ... }:

{
  programs = {
    # Configuration for zoxide, a smarter cd command
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      shellAliases = {
        cd = "z";
        cdi = "zi";
      };
    };
  };
}
