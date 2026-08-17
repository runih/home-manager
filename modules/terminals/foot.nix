{ lib, homeDirectory, ... }:
{
  # Default "no override" stub — a theme switcher (see hosts/linux/macnix)
  # can overwrite this with initial-color-theme=light/dark so *new* foot
  # windows open in the last-selected theme. Already-open windows switch
  # instantly via SIGUSR1 (colors-dark) / SIGUSR2 (colors-light).
  xdg.configFile."foot/current-theme.ini" = {
    text = lib.mkDefault "";
    force = true;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka Nerd Font Propo:size=11";
        dpi-aware = "yes";
        # foot requires include= to be an absolute path.
        include = "${homeDirectory}/.config/foot/current-theme.ini";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      "colors-light" = {
        foreground = "4c4f69";
        background = "eff1f5";
        regular0 = "5c5f77";
        regular1 = "d20f39";
        regular2 = "40a02b";
        regular3 = "df8e1b";
        regular4 = "1e66f5";
        regular5 = "ea76cb";
        regular6 = "179299";
        regular7 = "acb0be";
        bright0 = "6c6f85";
        bright1 = "d20f39";
        bright2 = "40a02b";
        bright3 = "df8e1b";
        bright4 = "1e66f5";
        bright5 = "ea76cb";
        bright6 = "179299";
        bright7 = "bcc0cc";
      };
    };
  };
}
