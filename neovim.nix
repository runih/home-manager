{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "673a6e3b2816d6e528fba42825ff2cc858f6f4fe";
    hash = "sha256-ILDtACjcTIpS9XHaYC7RP05kPxdfwLOXj1DPOE/mTGo=";
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
