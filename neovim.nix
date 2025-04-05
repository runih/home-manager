{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "50d85749357968efffdc1ac3101737bac868a22b";
    hash = "sha256-5JXejLNVGJpte3dFJTaqd9aFB8CBUrehILaKkWluDpw=";
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
