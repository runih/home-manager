{ pkgs, homeDirectory, config, lib, ... }:
{
  # Hosts that also pull in m.neovim already get a configured nvim via
  # programs.neovim; only fall back to a bare package when they don't.
  home.packages = lib.optional (!config.programs.neovim.enable) pkgs.neovim;

  programs.neovide = {
    enable = true;
    settings = {
      fork = true;
      frame = "full";
      idle = true;
      minimized = false;
      neovim-bin = "${homeDirectory}/.nix-profile/bin/nvim";
      no-multigrid = false;
      srgb = false;
      tabs = true;
      theme = "auto";
      title-hidden = true;
      vsync = true;
      wsl = false;

      cursor-visual-mode-insert = true;
      cursor-visual-mode-normal = true;
      cursor-visual-mode-replace = true;


      font = {
        normal = [ "Iosevka Nerd Font"];
        size = 16.0;
        hinting = "full";
        edging = "antialias";
      };
    };
  };
}
