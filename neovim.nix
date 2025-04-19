{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "3f3ea40813420acd92bb23235b92fd802fb7c296";
    hash = "sha256-Jb7dJDntIwXNKAXZBLalZoMhPqeXjp1KTidcfBsXRnw=";
  };
in
  {
  home = {
    packages = with pkgs; [
      nodejs_23
      gnumake
      gcc
      lazygit
      rustup
      w3m
    ];
  };
  programs = {
    neovim = {
      enable = true;
    };
  };

  xdg.configFile.nvim = {
    source = my-neovim-config;
    recursive = true;
  };
}
