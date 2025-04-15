{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "b3b8d655ada750e1da2620c1de29ead92d998b1e";
    hash = "sha256-Cakv/w5jGI0HD2vQZU/OY9CT+e/Ye41LuJe/vKZuPB4=";
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
