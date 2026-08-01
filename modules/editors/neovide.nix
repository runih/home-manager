{ homeDirectory, ... }:
{
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
