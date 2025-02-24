{ ... }:
{
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
      local config = {
        font_size = 17.0,
        window_decorations = "RESIZE",
        enable_tab_bar = false,
        -- color_scheme = "3024 Night",
        -- color_scheme = "myTheme",
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
