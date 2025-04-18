{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "3af3c174b9c5a8e5594e8886318d98a11b7df6d3";
    hash = "sha256-NvTIiLBkv/EaCjHAJE/PEW91pKGs+vGg1dfllKQ34Hk=";
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
