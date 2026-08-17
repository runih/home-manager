{ lib, ... }:
{
  # Default "no override" stub — a theme switcher (see hosts/linux/macnix)
  # can overwrite this with `return "<scheme name>"` and wezterm will pick it
  # up live via the reload watch list below, without touching this file.
  home.file.".config/wezterm/current-theme.lua" = {
    text = lib.mkDefault "return nil\n";
    force = true;
  };

  programs.wezterm = {
    enable = true;
    colorSchemes = {
      myTheme = {
        ansi = [
          "#222222" "#D14949" "#48874F" "#AFA75A"
          "#599797" "#8F6089" "#5C9FA8" "#8C8C8C"
        ];
        brights = [
          "#444444" "#FF6D6D" "#89FF95" "#FFF484"
          "#97DDFF" "#FDAAF2" "#85F5DA" "#E9E9E9"
        ];
        background = "#1B1B1B";
        cursor_bg = "#BEAF8A";
        cursor_border = "#BEAF8A";
        cursor_fg = "#1B1B1B";
        foreground = "#BEAF8A";
        selection_bg = "#444444";
        selection_fg = "#E9E9E9";
      };
    };
    enableZshIntegration = true;
    extraConfig = ''
      local scheme_ok, scheme = pcall(dofile, wezterm.config_dir .. "/current-theme.lua")
      if scheme_ok then
        wezterm.add_to_config_reload_watch_list(wezterm.config_dir .. "/current-theme.lua")
      end

      local config = {
        font_size = 17.0,
        window_decorations = "NONE",
        enable_tab_bar = false,
        color_scheme = scheme_ok and scheme or nil,
        send_composed_key_when_left_alt_is_pressed = true,
        cursor_blink_rate = 700,
        cursor_blink_ease_in = 'EaseIn',
        cursor_blink_ease_out = 'EaseOut',
        default_cursor_style = 'BlinkingBlock',
        colors = {
          compose_cursor = 'yellow',
          cursor_bg = 'yellow',
          cursor_fg = 'blue',
          cursor_border = 'yellow',
        }
      }
      return config
    '';
  };
}
