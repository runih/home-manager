{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "77720ead7f36863c597701914c775e234fa8aced";
    hash = "sha256-h94JV+ue8qDi76JpldwkPj65UZHYCXKKeVPfKuPpCoI=";
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
