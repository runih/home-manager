{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      hyprpaper
      hyprpicker
      ghostty
      wofi
      wl-clipboard
      cliphist
      swaynotificationcenter
      pavucontrol
      graphite-gtk-theme
      nwg-look
      gimp
    ];
    file.".config/waybar/scripts/launch.sh" = {
      text = ''
        #!/usr/bin/env bash

        PID=$(ps -e | grep waybar | head -n1 | awk '{print $1}')
        kill $PID

        waybar &
      '';
      executable = true;
    };
  };

  programs = {
    hyprshot = { enable = true; };
    hyprlock = { enable = true; };
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          margin-top = 5;
          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "custom/media" ];
          modules-right = [
            "pulseaudio"
            "network"
            "backlight"
            "battery"
            "clock"
            "power-profiles-daemon"
          ];
          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{icon}";
            format-icons = {
              urgent = "";
              active = "";
              default = "";
            };
          };
          "clock" = {
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            format-alt = "{:%Y-%m-%d}";
          };
          backlight = {
            format = "{percent}% {icon}";
            format-icons = [ "" "" "" "" "" "" "" "" "" ];
          };
          battery = {
            states = {
              # "good": 95,
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            # "format-good": "", // An empty format will hide the module
            # "format-full": "",
            format-icons = [ "" "" "" "" "" ];
          };
          power-profiles-daemon = {
            format = "{icon}";
            tooltip-format = ''
              Power profile: {profile}
              Driver: {driver}'';
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };
          network = {
            # "interface": "wlp2*", // (Optional) To force the use of this interface
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
          pulseaudio = {
            # "scroll-step": 1, // %, can be a float
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
          };
          "custom/media" = {
            format = "{icon} {text}";
            return-type = "json";
            max-length = 40;
            format-icons = {
              spotify = "";
              default = "🎜";
            };
            escape = true;
            exec =
              "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
          };
        };
      };
      style = ''
        * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: 'SF Pro Text', 'JetBrainsMono Nerd Font Propo', sans-serif;
          font-size: 13px;
          /* font-weight: bold;*/
          border-radius: 10px;
        }

        window#waybar {
          background-color: transparent;
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
        }

        /* you can set a style on hover for any module like this */
        #pulseaudio:hover {
          background-color: #a37800;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
          transition: 0.2s ease-in-out;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.focused {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #workspaces button.active {
          color: #05E8A3;
        }

        #workspaces button.empty {
          color: #09182D;
        }

        #workspaces button.empty.active {
          color: #ffffff;
        }

        #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #scratchpad,
        #power-profiles-daemon,
        #mpd {
          padding: 0 13px;
          color: #ffffff;
          margin: 0 5px;
        }

        #window,
        #workspaces {
          margin: 0 4px;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left>widget:first-child>#workspaces {
          margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right>widget:last-child>#workspaces {
          margin-right: 0;
        }

        #clock {
          background-color: #222647;
        }

        #battery {
          background-color: #222647;
          color: #ffffff;
        }

        #battery.charging,
        #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: #000000;
          }
        }

        /* Using steps() instead of linear as a timing function to limit cpu usage */
        #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #power-profiles-daemon {
          padding-right: 15px;
        }

        #power-profiles-daemon.performance {
          background-color: #222647;
          color: #ffffff;
        }

        #power-profiles-daemon.balanced {
          background-color: #222647;
          color: #ffffff;
        }

        #power-profiles-daemon.power-saver {
          background-color: #222647;
          color: #ffffff;
        }

        label:focus {
          background-color: #000000;
        }

        #cpu {
          background-color: #2ecc71;
          color: #000000;
        }

        #memory {
          background-color: #9b59b6;
        }

        #disk {
          background-color: #964B00;
        }

        #backlight {
          background-color: #222647;
        }

        #network {
          background-color: #222647;
        }

        #network.disconnected {
          background-color: #f53c3c;
        }

        #pulseaudio {
          background-color: #222647;
          color: #ffffff;
        }

        #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
        }

        #wireplumber {
          background-color: #222647;
          color: #000000;
        }

        #wireplumber.muted {
          background-color: #f53c3c;
        }

        #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
        }

        #custom-media.custom-spotify {
          background-color: #66cc99;
        }

        #custom-media.custom-vlc {
          background-color: #ffa000;
        }

        #temperature {
          background-color: #f0932b;
        }

        #temperature.critical {
          background-color: #eb4d4b;
        }

        #tray {
          background-color: #2980b9;
        }

        #tray>.passive {
          -gtk-icon-effect: dim;
        }

        #tray>.needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
        }

        #idle_inhibitor {
          background-color: #2d3436;
        }

        #idle_inhibitor.activated {
          background-color: #222647;
          color: #2d3436;
        }

        #mpd {
          background-color: #66cc99;
          color: #2a5c45;
        }

        #mpd.disconnected {
          background-color: #f53c3c;
        }

        #mpd.stopped {
          background-color: #90b1b1;
        }

        #mpd.paused {
          background-color: #51a37a;
        }

        #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
        }

        #keyboard-state {
          background: #97e1ad;
          color: #000000;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
        }

        #keyboard-state>label {
          padding: 0 5px;
        }

        #keyboard-state>label.locked {
          background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad {
          background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad.empty {
          background-color: transparent;
        }

        #privacy {
          padding: 0;
        }

        #privacy-item {
          padding: 0 5px;
          color: white;
        }

        #privacy-item.screenshare {
          background-color: #cf5700;
        }

        #privacy-item.audio-in {
          background-color: #1ca000;
        }

        #privacy-item.audio-out {
          background-color: #0069d4;
        }
      '';
    };
  };

  services = { hyprshell = { enable = true; }; };
}
