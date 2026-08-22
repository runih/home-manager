{ pkgs, ... }:
let
  themes = import ./themes.nix;
  defaultPalette = themes.themes.${themes.default};
  # Built against stable pkgs (not pkgsUnstable) because macnix's system
  # Hyprland (from programs.hyprland in hosts/linux/macnix/nixos, now
  # pinned to nixos-26.05) runs 0.55.4 — the same version stable pkgs.hyprland
  # here ships. Hyprland plugins are ABI-pinned to the exact source headers
  # of the running compositor, so a mismatch (e.g. building against
  # nixpkgs-unstable's 0.56.2) makes Hyprland show a version-mismatch error
  # banner on login instead of loading the plugin.
  hyprexpo = pkgs.hyprlandPlugins.mkHyprlandPlugin {
    pluginName = "hyprexpo";
    version = "0.55.4";
    src = pkgs.fetchFromGitHub {
      owner = "sandwichfarm";
      repo = "hyprexpo";
      rev = "v0.55.4";
      hash = "sha256-sERoTu9NcGD0RA3jAdHc4GOPkRbgqMrgDT8f7+Jv9fc=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      mv hyprexpo.so $out/lib/libhyprexpo.so
      runHook postInstall
    '';
    meta = with pkgs.lib; {
      homepage = "https://github.com/sandwichfarm/hyprexpo";
      description = "Maintained fork of the Hyprland expose-style workspace overview plugin";
      license = licenses.bsd3;
      platforms = platforms.linux;
    };
  };
in {
  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || (~/bin/render-calendar; hyprlock)";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 120;
          on-timeout = "sh -c '[ \"$(cat /sys/class/power_supply/ADP1/online)\" = 1 ] || powerprofilesctl set power-saver'";
          on-resume = "powerprofilesctl set balanced";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        systemd.enable = true;
        plugins = [ hyprexpo ];
        extraConfig = ''
          local mainMod = "SUPER"
          local terminal = "ghostty"
          local terminal2 = "wezterm"
          local editor = "neovide"
          local fileManager = "nautilus"
          local logout = "wlogout"

          os.execute("(sleep 0.5 && hyprctl notify -1 2000 'rgb(7aa2f7)' 'Config reloaded') &")

          hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.5 })
          hl.monitor({ output = "DP-1",  mode = "preferred", position = "auto", scale = "auto" })
          hl.monitor({ output = "",      mode = "preferred", position = "auto", scale = "auto" })

          hl.config({
            general = {
              gaps_in    = 3,
              gaps_out   = 10,
              border_size = 2,
              ["col.active_border"]   = { colors = {"rgba(${defaultPalette.borderActive1}ff)", "rgba(${defaultPalette.teal}ff)"}, angle = 45 },
              ["col.inactive_border"] = "rgb(${defaultPalette.border})",
              layout     = "dwindle",
            },
            decoration = {
              rounding = 4,
            },
            input = {
              kb_layout  = "se",
              kb_options = "lv3:lalt_switch,apple:alupckeys",
              kb_model   = "apple",
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
            plugin = {
              hyprexpo = {
                -- drag_drop_enable was added after the v0.55.4 tag this
                -- plugin build is pinned to (see comment above hyprexpo
                -- definition) — the older binary rejects it as an unknown
                -- config key.
                columns = 3,
                gaps_in = 5,
                gaps_out = 10,
                bg_col = "rgb(111111)",
                workspace_method = "center current",
                gesture_distance = 200,
                cancel_key = "escape",
                show_cursor = 1,
              },
            },
          })

          hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
          hl.bind(mainMod .. " + Space",        hl.dsp.exec_cmd("wofi --show drun --allow-images"))
          hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd("rofi -show drun"))
          hl.bind(mainMod .. " + ALT + Space",   hl.dsp.exec_cmd("rofi -show drun"))
          hl.bind(mainMod .. " + C",      hl.dsp.window.close())
          hl.bind(mainMod .. " + V",      hl.dsp.window.float())
          hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
          hl.bind(mainMod .. " + h",      hl.dsp.focus({ direction = "left" }))
          hl.bind(mainMod .. " + j",      hl.dsp.focus({ direction = "down" }))
          hl.bind(mainMod .. " + k",      hl.dsp.focus({ direction = "up" }))
          hl.bind(mainMod .. " + l",      hl.dsp.focus({ direction = "right" }))
          local function vmove(dir)
            local function read_cmd(cmd)
              local h = io.popen(cmd); local s = h:read("*a"); h:close(); return s
            end
            local aw   = read_cmd("hyprctl activewindow -j")
            local ay   = tonumber(aw:match('"at":%s*%[%d+,%s*(%d+)'))  or 0
            local ah   = tonumber(aw:match('"size":%s*%[%d+,%s*(%d+)')) or 0
            local ax   = tonumber(aw:match('"at":%s*%[(%d+)'))          or 0
            local bot  = ay + ah
            local cs   = read_cmd("hyprctl clients -j")
            local need_toggle = false
            local function iter() return cs:gmatch('"at":%s*%[(%d+),%s*(%d+)%]') end
            if dir == "up" then
              local has_above = false
              for _, cy in iter() do if tonumber(cy) < ay then has_above = true; break end end
              if not has_above then
                for cx, cy in iter() do
                  if tonumber(cy) == ay and tonumber(cx) ~= ax then need_toggle = true; break end
                end
              end
            else
              local has_below = false
              for _, cy in iter() do if tonumber(cy) >= bot then has_below = true; break end end
              if not has_below then
                for cx, cy in iter() do
                  if tonumber(cy) == ay and tonumber(cx) ~= ax then need_toggle = true; break end
                end
              end
            end
            if need_toggle then hl.dispatch(hl.dsp.layout("togglesplit")) end
            hl.dispatch(hl.dsp.window.move({ direction = dir }))
          end

          hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
          hl.bind(mainMod .. " + SHIFT + J", function() vmove("down") end)
          hl.bind(mainMod .. " + SHIFT + K", function()
            os.execute("hyprctl notify -1 2000 'rgb(ff0000)' 'K: before togglesplit'")
            hl.dispatch(hl.dsp.layout("togglesplit"))
            os.execute("hyprctl notify -1 2000 'rgb(00ff00)' 'K: after togglesplit'")
            hl.dispatch(hl.dsp.window.move({ direction = "up" }))
          end)
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
          hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d spi::kbd_backlight set 10%+"),   { locked = true, repeating = true })
          hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d spi::kbd_backlight set 10%-"),   { locked = true, repeating = true })
          hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { locked = true })
          hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                { locked = true })
          hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                          { locked = true })
          hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                          { locked = true })
          hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                            { locked = true })

          hl.bind(mainMod .. " + SHIFT + Return",   hl.dsp.exec_cmd(terminal2))
          hl.bind(mainMod .. " + M",                hl.dsp.exec_cmd(logout))
          hl.bind(mainMod .. " + E",                hl.dsp.exec_cmd(fileManager))
          hl.bind(mainMod .. " + I",                hl.dsp.exec_cmd("rofi-network-manager"))
          hl.bind(mainMod .. " + N",                hl.dsp.exec_cmd(editor))
          hl.bind(mainMod .. " + R",                hl.dsp.exec_cmd("hyprctl reload"))
          hl.bind(mainMod .. " + CTRL + Q",         hl.dsp.exec_cmd("~/bin/render-calendar; hyprlock"))
          hl.bind(mainMod .. " + W",                hl.dsp.exec_cmd("~/bin/change_wallpaper"))
          hl.bind(mainMod .. " + SHIFT + W",        hl.dsp.exec_cmd("~/bin/change_wallpaper --random"))
          hl.bind(mainMod .. " + SHIFT + T",        hl.dsp.exec_cmd("~/bin/theme-switch"))
          hl.bind(mainMod .. " + CTRL + 3",         hl.dsp.exec_cmd("hyprshot -m window"))
          hl.bind(mainMod .. " + CTRL + 4",         hl.dsp.exec_cmd("hyprshot -m region"))
          hl.bind(mainMod .. " + SHIFT + CTRL + 4", hl.dsp.exec_cmd("hyprshot -m output"))
          hl.bind(mainMod .. " + SHIFT + F",        hl.dsp.window.fullscreen({ mode = 1 }))
          hl.bind(mainMod .. " + P",                hl.dsp.window.pseudo())
          hl.bind(mainMod .. " + T",                hl.dsp.layout("togglesplit"))
          hl.bind(mainMod .. " + S",                hl.dsp.workspace.toggle_special("magic"))
          hl.bind(mainMod .. " + SHIFT + S",        hl.dsp.window.move({ workspace = "special:magic" }))
          hl.bind(mainMod .. " + O",                function() hl.plugin.hyprexpo.expo("toggle") end)
        '';
      };
    };
  };
}
