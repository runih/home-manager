{ pkgs, ... }:
let
  batteryScript = pkgs.writeShellScript "waybar-battery" ''
    online=$(cat /sys/class/power_supply/ADP1/online)
    status=$(cat /sys/class/power_supply/BAT0/status)
    charge_now=$(cat /sys/class/power_supply/BAT0/charge_now)
    charge_full=$(cat /sys/class/power_supply/BAT0/charge_full)
    capacity=$(( charge_now * 100 / charge_full ))

    if [ "$online" = "1" ]; then
      if [ "$status" = "Charging" ]; then
        printf '{"text":"󰂄 %s%%","class":"charging"}\n' "$capacity"
      else
        printf '{"text":"󰚥 %s%%","class":"plugged"}\n' "$capacity"
      fi
    else
      if   [ "$capacity" -le 20 ]; then icon="󰁺"; class="critical"
      elif [ "$capacity" -le 30 ]; then icon="󰁻"; class="warning"
      elif [ "$capacity" -le 60 ]; then icon="󰁽"; class=""
      elif [ "$capacity" -le 80 ]; then icon="󰁿"; class=""
      else icon="󰂂"; class=""
      fi
      printf '{"text":"%s %s%%","class":"%s"}\n' "$icon" "$capacity" "$class"
    fi
  '';
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [
        "clock"
      ];
      modules-right = [
        "tray"
        "wireplumber"
        "network"
        "cpu"
        "memory"
        "custom/power"
      ];

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          urgent = "";
          default = "";
        };
        sort-by-number = true;
      };

      "hyprland/submap" = {
        format = "✦ {}";
        max-length = 24;
        tooltip = false;
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%Y-%m-%d %H:%M}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = "󰍛 {usage}%";
        tooltip = false;
        interval = 5;
      };

      memory = {
        format = "󰘚 {percentage}%";
        interval = 5;
      };

      "custom/power" = {
        exec = "${batteryScript}";
        interval = 5;
        return-type = "json";
        format = "{}";
      };

      network = {
        format-wifi = "󰤨 {essid}";
        format-ethernet = "󰈀 {ifname}";
        format-disconnected = "⚠ Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        on-click = "nm-connection-editor";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        on-click = "pavucontrol";
        format-icons = [ "󰕿" "󰖀" "󰕾" ];
      };

      tray = {
        spacing = 8;
      };
    }];

    style = ''
      * {
        font-family: "Hack Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background-color: transparent;
        color: #c0caf5;
      }

      .modules-left, .modules-right, .modules-center {
        padding: 0 4px;
      }

      #workspaces,
      #submap,
      #clock {
        background-color: rgba(26, 27, 38, 0.9);
        border-radius: 8px;
        margin: 4px 3px;
        padding: 2px 10px;
      }

      .modules-right {
        background-color: rgba(26, 27, 38, 0.9);
        border-radius: 8px;
        margin: 4px 6px;
        padding: 2px 4px;
      }

      #cpu,
      #memory,
      #network,
      #wireplumber,
      #tray,
      #custom-power {
        background-color: transparent;
        border-radius: 0;
        margin: 0;
        padding: 2px 6px;
      }

      #workspaces button {
        padding: 0 4px;
        color: #565f89;
        background: transparent;
        border-radius: 6px;
      }

      #workspaces button.active {
        color: #7aa2f7;
        background: rgba(122, 162, 247, 0.15);
      }

      #workspaces button.urgent {
        color: #f7768e;
      }

      #clock {
        color: #7dcfff;
        font-weight: bold;
      }

      #custom-power {
        color: #9ece6a;
      }

      #custom-power.warning {
        color: #e0af68;
      }

      #custom-power.critical {
        color: #f7768e;
        animation: blink 1s linear infinite;
      }

      @keyframes blink {
        0%   { color: #f7768e; }
        50%  { color: transparent; }
        100% { color: #f7768e; }
      }

      #network {
        color: #2ac3de;
      }

      #cpu {
        color: #bb9af7;
      }

      #memory {
        color: #73daca;
      }

      #wireplumber {
        color: #ff9e64;
      }

      #wireplumber.muted {
        color: #565f89;
      }

      #tray {
        padding: 2px 6px;
      }

      #submap {
        color: #f7768e;
        font-weight: bold;
      }

      tooltip {
        background: rgba(26, 27, 38, 0.95);
        border: 1px solid #414868;
        border-radius: 8px;
      }
    '';
  };
}
