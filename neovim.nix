{ pkgs, ... }:
let
  my-neovim-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "neovim-lua-config";
    rev = "d49996e35941207d3f4db14081208a723bbb22c2";
    hash = "sha256-ccMspTqY4wmb11PJKAa315dUOcehdj9cMFQZSQCFO8Q=";
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
