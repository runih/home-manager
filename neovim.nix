{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "108ec52dddbb0232bea9c3c4c08c64c94a1b5c18";
    hash = "sha256-GsEl9VchgSYRm0Ues9H3CQ5Gxpd/bojynX6ShIPs0FY=";
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
