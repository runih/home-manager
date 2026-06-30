{ pkgs, ... }: {
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
        "battery"
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
        format = " {usage}%";
        tooltip = false;
        interval = 5;
      };

      memory = {
        format = " {percentage}%";
        interval = 5;
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };

      network = {
        format-wifi = " {essid}";
        format-ethernet = " {ifname}";
        format-disconnected = "⚠ Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        on-click = "nm-connection-editor";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = " muted";
        on-click = "pavucontrol";
        format-icons = [ "" "" "" ];
      };

      tray = {
        spacing = 8;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(26, 27, 38, 0.9);
        color: #c0caf5;
        border-bottom: 2px solid rgba(41, 49, 90, 0.8);
      }

      .modules-left, .modules-right, .modules-center {
        padding: 0 8px;
      }

      #workspaces button {
        padding: 0 6px;
        margin: 3px 0;
        color: #565f89;
        background: transparent;
      }

      #workspaces button.active {
        color: #7aa2f7;
        background: rgba(122, 162, 247, 0.15);
      }

      #workspaces button.urgent {
        color: #f7768e;
        border-bottom: 2px solid #f7768e;
      }

      #clock {
        color: #7dcfff;
        font-weight: bold;
      }

      #battery {
        color: #9ece6a;
      }

      #battery.warning {
        color: #e0af68;
      }

      #battery.critical {
        color: #f7768e;
        animation: blink 0.5s step-end infinite alternate;
      }

      @keyframes blink {
        to { color: #1a1b26; background-color: #f7768e; }
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
        padding: 0 4px;
      }

      #submap {
        color: #f7768e;
        font-weight: bold;
      }

      tooltip {
        background: rgba(26, 27, 38, 0.95);
        border: 1px solid #414868;
        border-radius: 4px;
      }
    '';
  };
}
