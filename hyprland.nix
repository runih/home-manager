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
      swaylock-effects
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
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = false;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [{ path = "$HOME/Pictures/wallpapers/key7.png"; }];

        input-field = [{
          size = "400, 50";
          outline_thickness = 3;
          dots_size = 0.33; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true;
          dots_rounding = -1; # -1 default, -2 follow input-field rounding
          outer_color = "rbg(151515)";
          inner_color = "rbg(FFFFFF)";
          font_color = "rbg(10, 10, 10)";
          fade_on_empty = true;
          fade_timeout = 1000; # Milliseconds before fade_on_empty is triggered.
          placeholder_text =
            "'<i>Enter Password...</i>'"; # Text rendered in the input box when it's empty
          hide_input = false;
          rounding = -1; # -1 means complete rounding (circle/oval)
          check_color = "rbg(204, 136, 34)";
          fail_color =
            "rbg(204, 34, 34)"; # if authentication failed, changes outer_color and fail message color
          fail_text = "'<i>$FAIL <b>($ATTEMPTS)</b></i>'"; # can be set to empty
          fail_transition =
            300; # transition time in ms between normal outer_color and fail_color
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color =
            -1; # when both locks are active. -1 means don't change outer color (same for above)
          invert_numlock = false; # change color if numlock is off
          swap_font_color = false; # see below
          position = "0, -20";
          halign = "center";
          valign = "center";
        }];

        label = [
          {
            text = ''cmd[update:1000] echo "$(date +'%V')"'';
            color = "rgba(200, 200, 200, 0.1)";
            font_size = 250;
            font_family = "Fira Semibold";
            position = "-10, 20";
            halign = "right";
            valign = "top";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = ''cmd[update:1000] echo "$(date +'%A')"'';
            color = "rgba(200, 200, 200, 0.1)";
            font_size = 120;
            font_family = "Fira Semibold";
            position = "50, 180";
            halign = "left";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = ''cmd[update:1000] echo "$(date +'%d %B %Y')"'';
            color = "rgba(200, 200, 200, 0.1)";
            font_size = 120;
            font_family = "Fira Semibold";
            position = "50, 20";
            halign = "left";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = ''cmd[update:1000] echo "$TIME"'';
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 55;
            font_family = "Fira Semibold";
            position = "-50, 50";
            halign = "right";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            text = "$USER";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 20;
            font_family = "Fira Semibold";
            position = "-50, 150";
            halign = "right";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
        ];

      };
    };
    wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
      style = ''
        * {
          font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
        	background-image: none;
        	box-shadow: none;
          transition: 50ms;
        }

        window {
        	background-color: rgba(12, 12, 12, 0.7);
        }

        button {
          color: #FFFFFF;
          border-radius: 20px;
          
        	background-color: rgba(12, 12, 12, 0.8);
        	background-repeat: no-repeat;
        	background-position: center;
        	background-size: 25%;
          
        	border-style: solid;
          border: 3px solid #15171B;
          margin: 10px;

          box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
        }

        button:focus,
        button:active,
        button:hover {
          color: #15171C;
        	background-color: rgba(12, 12, 12, 0.9);
          border: 3px solid #01F092;
        }

        #lock {
            background-image: image(url("/nix/store/mcf8r67jp80nkxbkq9y460z6d4gyjbyn-wlogout-1.2.2/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
        }

        #logout {
            background-image: image(url("/nix/store/mcf8r67jp80nkxbkq9y460z6d4gyjbyn-wlogout-1.2.2/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
        }

        #suspend {
            background-image: image(url("/nix/store/mcf8r67jp80nkxbkq9y460z6d4gyjbyn-wlogout-1.2.2/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
        }

        #hibernate {
            background-image: image(url("/nix/store/mcf8r67jp80nkxbkq9y460z6d4gyjbyn-wlogout-1.2.2/share/wlogout/icons/hibernate.png"), url("/usr/local/share/wlogout/icons/hibernate.png"));
        }

        #shutdown {
            background-image: image(url("/nix/store/mcf8r67jp80nkxbkq9y460z6d4gyjbyn-wlogout-1.2.2/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
        }

        #reboot {
            background-image: image(url("/nix/store/mcf8r67jp80nkxbkq9y460z6d4gyjbyn-wlogout-1.2.2/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
        }
      '';
    };
    chromium = {
      enable = true;
      extensions = [
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }
        { id = "nhdogjmejiglipccpnnnanhbledajbpd"; }
      ];
    };
  };

  services = {
    hyprshell.enable = true;

    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
