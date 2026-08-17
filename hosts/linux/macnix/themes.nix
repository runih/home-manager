{
  default = "tokyo-night";

  # Each palette covers every color role used across hyprland borders,
  # waybar, and wofi so a theme switch stays visually coherent.
  # borderActive1 = primary hyprland active-border gradient color (hex, no #)
  # teal          = secondary hyprland gradient color / waybar "memory" accent
  # border        = hyprland inactive border / waybar+wofi border color
  # bg / bgRgb     = base translucent background (hex + "r, g, b" decimal)
  # bg2           = wofi input field background
  # fg / fg2      = primary / secondary text
  # muted         = inactive workspace + muted icons
  # blue / blueRgb = primary accent (active workspace, wofi focus outline)
  # red, green, yellow, orange, cyan, purple = status colors
  # mode          = "dark" or "light" — picks which terminal (wezterm/foot/
  #                 ghostty) color set theme-switcher.nix applies
  themes = {
    tokyo-night = {
      mode          = "dark";
      borderActive1 = "1a4fc4";
      teal          = "73daca";
      border        = "414868";
      bg            = "1a1b26";
      bgRgb         = "26, 27, 38";
      bg2           = "1e2030";
      fg            = "c0caf5";
      fg2           = "a9b1d6";
      muted         = "565f89";
      blue          = "7aa2f7";
      blueRgb       = "122, 162, 247";
      red           = "f7768e";
      green         = "9ece6a";
      yellow        = "e0af68";
      orange        = "ff9e64";
      cyan          = "7dcfff";
      netCyan       = "2ac3de";
      purple        = "bb9af7";
      wallpaperDir  = "tokyo-night";
    };

    catppuccin-mocha = {
      mode          = "dark";
      borderActive1 = "89b4fa";
      teal          = "94e2d5";
      border        = "313244";
      bg            = "1e1e2e";
      bgRgb         = "30, 30, 46";
      bg2           = "181825";
      fg            = "cdd6f4";
      fg2           = "bac2de";
      muted         = "6c7086";
      blue          = "89b4fa";
      blueRgb       = "137, 180, 250";
      red           = "f38ba8";
      green         = "a6e3a1";
      yellow        = "f9e2af";
      orange        = "fab387";
      cyan          = "89dceb";
      netCyan       = "89dceb";
      purple        = "cba6f7";
      wallpaperDir  = "catppuccin-mocha";
    };

    gruvbox-dark = {
      mode          = "dark";
      borderActive1 = "83a598";
      teal          = "8ec07c";
      border        = "504945";
      bg            = "282828";
      bgRgb         = "40, 40, 40";
      bg2           = "3c3836";
      fg            = "ebdbb2";
      fg2           = "d5c4a1";
      muted         = "928374";
      blue          = "83a598";
      blueRgb       = "131, 165, 152";
      red           = "fb4934";
      green         = "b8bb26";
      yellow        = "fabd2f";
      orange        = "fe8019";
      cyan          = "458588";
      netCyan       = "458588";
      purple        = "d3869b";
      wallpaperDir  = "gruvbox-dark";
    };

    nord = {
      mode          = "dark";
      borderActive1 = "81a1c1";
      teal          = "8fbcbb";
      border        = "4c566a";
      bg            = "2e3440";
      bgRgb         = "46, 52, 64";
      bg2           = "3b4252";
      fg            = "eceff4";
      fg2           = "e5e9f0";
      muted         = "4c566a";
      blue          = "81a1c1";
      blueRgb       = "129, 161, 193";
      red           = "bf616a";
      green         = "a3be8c";
      yellow        = "ebcb8b";
      orange        = "d08770";
      cyan          = "88c0d0";
      netCyan       = "88c0d0";
      purple        = "b48ead";
      wallpaperDir  = "nord";
    };

    catppuccin-latte = {
      mode          = "light";
      borderActive1 = "1e66f5";
      teal          = "179299";
      border        = "bcc0cc";
      bg            = "eff1f5";
      bgRgb         = "239, 241, 245";
      bg2           = "e6e9ef";
      fg            = "4c4f69";
      fg2           = "5c5f77";
      muted         = "9ca0b0";
      blue          = "1e66f5";
      blueRgb       = "30, 102, 245";
      red           = "d20f39";
      green         = "40a02b";
      yellow        = "df8e1b";
      orange        = "fe640b";
      cyan          = "04a5e5";
      netCyan       = "209fb5";
      purple        = "8839ef";
      wallpaperDir  = "catppuccin-latte";
    };
  };
}
