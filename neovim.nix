{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "8517e3e32535e5237613d612b566060e0ce3b481";
    hash = "sha256-59+MoR4/P9YDRNOPDiIbj+VstLCKUlnp4x8hCvvabB0=";
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
