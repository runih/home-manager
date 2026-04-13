{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "d46c5e2d4cf6d42c12e4af3ea282c3df4eb95a78";
    hash = "sha256-6cXOevAKx2R/ErXp/JOB7dDqRx7bzhDpTp7tPLobK4s=";
  };
in
  {
  home = {
    packages = with pkgs; [
      nodejs_22
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
