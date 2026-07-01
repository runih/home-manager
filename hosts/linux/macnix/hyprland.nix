{ pkgs, ... }: {
  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        systemd.enable = true;
        extraConfig = ''
          local mainMod = "SUPER"
          local terminal = "ghostty"
          local terminal2 = "wezterm"
          local editor = "neovide"
          local fileManager = "nautilus"
          local logout = "wlogout"

          hl.env("XCURSOR_SIZE", "24")
          hl.env("HYPRCURSOR_SIZE", "24")

          hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
          hl.monitor({ output = "DP-1",  mode = "preferred", position = "auto", scale = "auto" })
          hl.monitor({ output = "",      mode = "preferred", position = "auto", scale = "auto" })

          hl.config({
            general = {
              gaps_in    = 3,
              gaps_out   = 10,
              border_size = 2,
              ["col.active_border"]   = { colors = {"rgba(1a4fc4ff)", "rgba(73dacaff)"}, angle = 45 },
              ["col.inactive_border"] = "rgb(414868)",
              layout     = "dwindle",
            },
            decoration = {
              rounding = 4,
            },
            input = {
              kb_layout  = "se",
              kb_options = "lv3:lalt_switch",
              kb_model   = "apple:alupckeys",
              follow_mouse = 1,
              touchpad = {
                disable_while_typing = true,
                tap_to_click         = false,
                natural_scroll       = true,
              },
            },
            misc = {
              force_default_wallpaper = -1,
              disable_hyprland_logo   = false,
            },
          })

          hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
          hl.bind(mainMod .. " + Space",        hl.dsp.exec_cmd("rofi -show drun"))
          hl.bind(mainMod .. " + ALT + Space",   hl.dsp.exec_cmd("wofi --show drun"))
          hl.bind(mainMod .. " + C",      hl.dsp.window.close())
          hl.bind(mainMod .. " + V",      hl.dsp.window.float())
          hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
          hl.bind(mainMod .. " + h",      hl.dsp.focus({ direction = "left" }))
          hl.bind(mainMod .. " + j",      hl.dsp.focus({ direction = "down" }))
          hl.bind(mainMod .. " + k",      hl.dsp.focus({ direction = "up" }))
          hl.bind(mainMod .. " + l",      hl.dsp.focus({ direction = "right" }))
          hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
          hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
          hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
          hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

          for i = 1, 5 do
            hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
            hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
          end

          hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
          hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
          hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
          hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

          hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
          hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
          hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
          hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
          hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
          hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { locked = true })
          hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                { locked = true })
          hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                          { locked = true })
          hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                          { locked = true })
          hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                            { locked = true })

          hl.bind(mainMod .. " + SHIFT + Return",   hl.dsp.exec_cmd(terminal2))
          hl.bind(mainMod .. " + M",                hl.dsp.exec_cmd(logout))
          hl.bind(mainMod .. " + E",                hl.dsp.exec_cmd(fileManager))
          hl.bind(mainMod .. " + N",                hl.dsp.exec_cmd(editor))
          hl.bind(mainMod .. " + R",                hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
          hl.bind(mainMod .. " + CTRL + Q",         hl.dsp.exec_cmd("hyprlock"))
          hl.bind(mainMod .. " + W",                hl.dsp.exec_cmd("~/bin/change_wallpaper"))
          hl.bind(mainMod .. " + SHIFT + W",        hl.dsp.exec_cmd("~/bin/change_wallpaper --random"))
          hl.bind(mainMod .. " + CTRL + 3",         hl.dsp.exec_cmd("hyprshot -m window"))
          hl.bind(mainMod .. " + CTRL + 4",         hl.dsp.exec_cmd("hyprshot -m region"))
          hl.bind(mainMod .. " + SHIFT + CTRL + 4", hl.dsp.exec_cmd("hyprshot -m output"))
          hl.bind(mainMod .. " + SHIFT + F",        hl.dsp.window.fullscreen({ mode = 1 }))
          hl.bind(mainMod .. " + P",                hl.dsp.window.pseudo())
          hl.bind(mainMod .. " + T",                hl.dsp.layout("togglesplit"))
          hl.bind(mainMod .. " + S",                hl.dsp.workspace.toggle_special("magic"))
          hl.bind(mainMod .. " + SHIFT + S",        hl.dsp.window.move({ workspace = "special:magic" }))
        '';
      };
    };
  };
}
