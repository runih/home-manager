{ pkgs, ... }:
let
  themes = import ./themes.nix;
  themeLib = import ./theme-lib.nix;
  defaultPalette = themes.themes.${themes.default};

  gpuScript = pkgs.writeShellScript "waybar-gpu" ''
    busy=$(timeout 3 /run/wrappers/bin/intel_gpu_top -J -s 1000 -n 2 -o - 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '(.[-1].engines // {} | to_entries[] | select(.key | startswith("Render")) | .value.busy) // 0 | round')
    busy="''${busy:-0}"
    printf '{"text":"󰢮 %s%%","tooltip":"GPU busy: %s%%"}\n' "$busy" "$busy"
  '';

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
        "group/left-island"
        "custom/tmux"
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
        "custom/gpu"
        "memory"
        "custom/power"
      ];

      "group/left-island" = {
        orientation = "horizontal";
        modules = ["hyprland/workspaces" "hyprland/window"];
      };

      "custom/tmux" = {
        exec = "tmux display-message -p '#{session_name}: #{pane_current_command}' 2>/dev/null || echo ''";
        interval = 2;
        format = " {}";
        tooltip = false;
      };

      "hyprland/window" = {
        max-length = 50;
        separate-outputs = true;
      };

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

      "custom/gpu" = {
        exec = "${gpuScript}";
        interval = 5;
        return-type = "json";
        format = "{}";
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

    style = themeLib.mkWaybarStyle defaultPalette;
  };

  xdg.configFile."waybar/style.css".force = true;
}
