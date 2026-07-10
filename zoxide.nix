{ lib, pkgs, ... }:

{
  programs = {
    # Configuration for zoxide, a smarter cd command
    zoxide = {
      enable = true;
      # home-manager's own zsh integration inserts init at mkOrder 851
      # ("after compinit"), but other tools (oh-my-posh, fzf, eza aliases)
      # land at the default order 1000 and end up sourced *after* it. zoxide
      # needs to be initialized last, so integrate manually at a later order
      # instead (mirroring the mkOrder 2000 home-manager already uses for bash).
      enableZshIntegration = false;
    };

    zsh = {
      shellAliases = {
        cd = "z";
        cdi = "zi";
      };
      initContent = lib.mkOrder 2000 ''
        eval "$(${lib.getExe pkgs.zoxide} init zsh)"
      '';
    };
  };
}
