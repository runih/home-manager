{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      hyprpaper
      hyprpicker
      wofi
      walker
      wl-clipboard
      cliphist
      swaynotificationcenter
      pavucontrol
      graphite-gtk-theme
      nwg-look
      gimp
      swaylock-effects
      jq
      brave
      quickshell
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
    file."bin/change_wallpaper" = {
      text = ''
        #!/usr/bin/env bash
        WALLPAPERS="$HOME/Pictures/wallpapers/"
        if [ "$1" == "--random" ] || [ "$1" == "-r" ]; then
          WALLPAPER=$(ls $WALLPAPERS | shuf -n 1)
        else
          WALLPAPER=$(ls $WALLPAPERS | walker -d)
        fi
        if [ "$WALLPAPER" != "" ]; then
          swww img $WALLPAPERS$WALLPAPER --transition-fps=60 --transition-step=255 --transition-type=any
        fi
      '';
      executable = true;
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        settings = {
          # Set programs that you use
          "$editor" = "neovide";
          "$fileManager" = "nautilus";
          "$logout" = "wlogout";
          "$menu" = "walker";
          "$menu2" = "fuzzel";
          "$terminal" = "ghostty";
          "$terminal2" = "wezterm";

          #############################
          ### ENVIRONMENT VARIABLES ###
          #############################

          # See https://wiki.hyprland.org/Configuring/Environment-variables/

          env = [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          exec-once = [
            "waybar"
            "swww-daemon"
            "walker --gapplication-service"
          ];

          monitor = [
            "eDP-1,preferred,auto,1.5"
            "DP-1,preferred,auto,auto"
          ];

          workspace = [
            "1,monitor:DP-1"
            "2,monitor:DP-1"
            "4,monitor:eDP-1"
          ];

          general = {
              gaps_in = 3;
              gaps_out = 10;

              border_size = 1;

              # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
              "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
              "col.inactive_border" = "rgba(595959aa)";

              # Set to true enable resizing windows by clicking and dragging on borders and gaps
              resize_on_border = false;

              # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
              allow_tearing = false;

              layout = "dwindle";
          };

          decoration = {
              rounding = 10;
              rounding_power = 2;

              # Change transparency of focused and unfocused windows
              active_opacity = 1.0;
              inactive_opacity = 1.0;

              shadow = {
                  enabled = true;
                  range = 4;
                  render_power = 3;
                  color = "rgba(1a1a1aee)";
              };

              # https://wiki.hyprland.org/Configuring/Variables/#blur
              blur = {
                  enabled = true;
                  size = 3;
                  passes = 1;

                  vibrancy = 0.1696;
              };
          };


          animations = {
            enabled = "yes";

            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

            animation = [
              "windows, 1, 7, myBezier"
              "windowsIn, 1, 7, myBezier, slide"
              "windowsOut, 1, 7, myBezier, popin 87%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, myBezier, slide"
            ];
          };

          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          dwindle = {
              pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = true; # You probably want this
          };

          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          master = {
              new_status = "master";
          };

          # https://wiki.hyprland.org/Configuring/Variables/#misc
          misc = {
              force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
              disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
          };

          "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier
          bind = [
            # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
            "$mainMod, Return, exec, $terminal"
            "$mainMod SHIFT, Return, exec, $terminal2"
            "$mainMod, C, killactive,"
            "$mainMod, M, exec, $logout"
            "$mainMod, E, exec, $fileManager"
            "$mainMod, V, togglefloating,"
            "$mainMod, space, exec, $menu"
            "$mainMod SHIFT, space, exec, $menu2"
            "$mainMod, P, pseudo, # dwindle"
            "$mainMod, T, togglesplit, # dwindle"
            "$mainMod, R, exec, ~/.config/waybar/scripts/launch.sh"
            "$mainMod CTRL, Q, exec, hyprlock"
            "$mainMod, F, fullscreen, 0"
            "$mainMod SHIFT, F, fullscreen, 1"
            "$mainMod, W, exec, ~/bin/change_wallpaper"
            "$mainMod SHIFT, W, exec, ~/bin/change_wallpaper --random"
            "$mainMod, N, exec, $editor"
            "$mainMod CTRL, 3, exec, hyprshot -m window"
            "$mainMod CTRL, 4, exec, hyprshot -m region"
            "$mainMod SHIFT CTRL, 4, exec, hyprshot -m output"

            # Move focus with mainMod + arrow keys
            "$mainMod, h, movefocus, l"
            "$mainMod, j, movefocus, d"
            "$mainMod, k, movefocus, u"
            "$mainMod, l, movefocus, r"
            "$mainMod SHIFT, H, movewindow, l"
            "$mainMod SHIFT, J, movewindow, d"
            "$mainMod SHIFT, K, movewindow, u"
            "$mainMod SHIFT, L, movewindow, r"

            # Switch workspaces with mainMod + [0-9]
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"

            # Example special workspace (scratchpad)
            "$mainMod, S, togglespecialworkspace, magic"
            "$mainMod SHIFT, S, movetoworkspace, special:magic"

            # Scroll through existing workspaces with mainMod + scroll
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"
          ];

          bindm =[
            # Move/resize windows with mainMod + LMB/RMB and dragging
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];

          bindel = [
            # Laptop multimedia keys for volume and LCD brightness
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
            ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
          ];

          bindl = [
            # Requires playerctl
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPause, exec, playerctl play-pause"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
          ];

          input = {
                kb_layout = "se";
            kb_options = "lv3:lalt_switch";
            #kb_options = "lv3:lalt_switch,lv5:lsgt_switch";
            kb_model = "apple:alupckeys";
            #kb_variant = "mac";

            follow_mouse = 1;

            #sensitivity = -0.7; # -1.0 - 1.0, 0 means no modification.

            touchpad = {
                disable_while_typing = true;
                tap-to-click = false;
                natural_scroll = true;
            };

          };

          # https://wiki.hyprland.org/Configuring/Variables/#gestures
          gestures =  {
            gesture = [
              "3, horizontal, workspace"
              "4, down, close"
              "2, pinchin, scale: 1.5, fullscreen, 1"
              "2, pinchout, scale: 1.5, float"
            ];
          };

          # Example per-device config
          # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
          device ={
              name = "epic-mouse-v1";
              sensitivity = -0.5;
          };
          ##############################
          ### WINDOWS AND WORKSPACES ###
          ##############################

          # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
          # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

          # Example windowrule
          # windowrule = float,class:^(kitty)$,title:^(kitty)$

          # Ignore maximize requests from apps. You'll probably like this.
          windowrule = [
            "suppressevent maximize, class:.*"

            # Fix some dragging issues with XWayland
            "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          ];

          # Start some apps on specific workspaces
          windowrulev2 = [
            "workspace 1, class:neovide"
            "workspace 2, class:firefox"
            "workspace 2, class:vivaldi-stable"
            "workspace 4, class:brave-browser"
            #"workspace 3, class:com.mitchellh.ghostty"
            "opacity 0.3 0.3, title:^(walker)$"
            "workspace 5, class:teams-for-linux"
            "workspace 6, class:thunderbird"
            "workspace 7, class:code # VSCode"
            "workspace 10, class:org.gnome.SystemMonitor"
          ] ;
        };
        systemd.enable = true;
      };
    };
  };

  programs = {
    alacritty = { 
      enable = true;
      settings = {
        font = {
          normal = {
            family = "Iosevka Nerd Font Mono";
            style = "Medium";
          };
          size = 14.0;
        };
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_padding = true;
          #decorations = "RESIZE";
        };
        #scrollback = {
        #history = 10000;
        #multiplier = 3;
        #};
      };
      theme = "solarized_dark";
    };
    hyprshot = { enable = true; };
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          margin-top = 5;
          modules-left = [ "hyprland/window" "custom/media" ];
          modules-center = [ "hyprland/workspaces"  ];
          modules-right = [
            "pulseaudio"
            "network"
            "bluetooth"
            "battery"
            "clock"
            "power-profiles-daemon"
          ];
          "hyprland/workspaces" = {
            "persistent-workspaces" = {
              "*" = 3;
            };
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{icon}";
             format-icons = {
             "1" = "";
             /* "2" = ""; */
             "2" = "";
             "3" = "";
             "4" = "";
             "5" = "";
             "6" = "";
             "7" = "";
             "10" = "";
            #   urgent = "";
            #   active = "";
            #   default = "";
             };
          };
          "clock" = {
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            format-alt = "{:%Y-%m-%d}";
          };
          bluetooth = {
            /* "controller": "controller1",  specify the alias of the controller if there are more than 1 on the system */
            format = " {status}";
            "format-disabled" =  ""; /* an empty format will hide the module */
            "format-connected" = " {num_connections} connected";
            "tooltip-format" =  "{controller_alias}\t{controller_address}";
            "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
            on-click = "blueman-manager";
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

        /*
        #workspaces {
          background-color: rgba(0, 0, 0, 0.2);
          padding: 6px;
        }
        */

        #workspaces button {
          border: 1px solid rgba(0, 0, 0, 0.2);
          border-radius: 10px;
          padding: 0 5px;
          background-color: rgba(0, 0, 0, 0.2);
          /* color: rgba(175, 175, 175, 0.7); */
          color: #ffffff;
          transition: 0.2s ease-in-out;
          margin: 2px;
          min-width: 30px;
        }

        #workspaces button:hover {
          color: #05E8A3;
          background: rgba(0, 0, 0, 0.2);
          min-width: 80px;
        }

        #workspaces button.focused {
          background-color: #64727D;
          /* box-shadow: inset 0 -3px #ffffff; */
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #workspaces button.active {
          color: #05E8A3;
          min-width: 80px;
        }

        #workspaces button.empty {
          /* color: #09182D; */
          color: rgba(175, 175, 175, 0.7);
        }

        #workspaces button.empty.active {
          /* color: #ffffff; */
          color: rgba(175, 175, 175, 0.7);
        }

        #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #bluetooth,
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
          /* background: rgba(14, 41, 70, 0.7); */
          background-color: rgba(0, 0, 0, 0.2);
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
          color: #ffffff;
        }

        #power-profiles-daemon.balanced {
          color: #ffffff;
        }

        #power-profiles-daemon.power-saver {
          color: #01EF95;
        }

        label:focus {
          background-color: #000000;
        }

        #network.disconnected {
          background-color: #f53c3c;
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
    fuzzel = {
      enable = true;
      settings = {
        main = {
          # output=<not set>
          font="Iosevka Nerd Font:style=Medium:size=18:antialias=true:autohint=true";
          dpi-aware="auto";
          # use-bold=no
          # prompt="> "
          # placeholder=
          # icon-theme=default
          # icons-enabled=yes
          # hide-before-typing=no
          # fields=filename,name,generic
          # password-character=*
          # filter-desktop=no
          # match-mode=fzf
          # sort-result=yes
          # match-counter=no
          # delayed-filter-ms=300
          # delayed-filter-limit=20000
          show-actions="yes";
          # terminal=$TERMINAL -e  # Note: you cannot actually use environment variables here
          # launch-prefix=<not set>
          # list-executables-in-path=no

          # anchor=center
          x-margin=5;
          y-margin=5;
          # lines=25
          # minimal-lines=no
          width=70;
          # tabs=8
          # horizontal-pad=40
          # vertical-pad=8
          # inner-pad=0

          # scaling-filter=box
          # image-size-ratio=0.5

          # gamma-correct-blending=no
          # line-height=<use font metrics>
          # letter-spacing=0

          layer="overlay";
          # keyboard-focus=exclusive
          # exit-on-keyboard-focus-loss=yes

          # cache=<not set>

          # render-workers=<number of logical CPUs>
          # match-workers=<number of logical CPUs>

          # enable-mouse=yes
        };
        colors = {
          background="282a36dd";
          text="f8f8f2ff";
          prompt="586e75ff";
          placeholder="93a1a1ff";
          input="657b83ff";
          match="8be9fdff";
          selection="44475add";
          selection-text="f8f8f2ff";
          selection-match="8be9fdff";
          counter="93a1a1ff";
          border="bd93f9ff";

        };
        border = {
          width=1;
          radius=10;
        };

        dmenu = {
          # mode=text  # text|index
          # exit-immediately-if-empty=no
        };

        key-bindings = {
          cancel="Escape Control+g Control+c Control+bracketleft";
          # execute=Return KP_Enter Control+y
          # execute-or-next=Tab
          # execute-input=Shift+Return Shift+KP_Enter
          # cursor-left=Left Control+b
          # cursor-left-word=Control+Left Mod1+b
          # cursor-right=Right Control+f
          # cursor-right-word=Control+Right Mod1+f
          # cursor-home=Home Control+a
          # cursor-end=End Control+e
          # delete-line=Control+Shift+BackSpace
          # delete-prev=BackSpace Control+h
          # delete-prev-word=Mod1+BackSpace Control+BackSpace Control+w
          # delete-line-backward=Control+u
          # delete-next=Delete KP_Delete Control+d
          # delete-next-word=Mod1+d Control+Delete Control+KP_Delete
          # delete-line-forward=Control+k
          prev="Up Control+j";
          # prev-with-wrap=ISO_Left_Tab
          # prev-page=Page_Up KP_Page_Up
          next="Down Control+n";
          # next-with-wrap=none
          # next-page=Page_Down KP_Page_Down
          # expunge="Control+u";
          # clipboard-paste=Control+v XF86Paste
          # primary-paste=Shift+Insert Shift+KP_Insert

          # custom-N: *dmenu mode only*. Like execute, but with a non-zero
          # exit-code; custom-1 exits with code 10, custom-2 with 11, custom-3
          # with 12, and so on.

          # custom-1=Mod1+1
          # custom-2=Mod1+2
          # custom-3=Mod1+3
          # custom-4=Mod1+4
          # custom-5=Mod1+5
          # custom-6=Mod1+6
          # custom-7=Mod1+7
          # custom-8=Mod1+8
          # custom-9=Mod1+9
          # custom-10=Mod1+0
          # custom-11=Mod1+exclam
          # custom-12=Mod1+at
          # custom-13=Mod1+numbersign
          # custom-14=Mod1+dollar
          # custom-15=Mod1+percent
          # custom-16=Mod1+dead_circumflex
          # custom-17=Mod1+ampersand
          # custom-18=Mod1+asterix
          # custom-19=Mod1+parentleft
        };
      };
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

        background = [{ path = "$HOME/Pictures/hyprlock/key7.png"; }];

        animations = {
          enabled = true;
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            "fadeIn, 1, 15, linear"
            "fadeOut, 1, 15, linear"
            "inputFieldDots, 1, 2, linear"
          ];
        };

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
            text = ''cmd[update:1000] cal -y'';
            color = "rgba(200, 200, 200, 0.1)";
            font_size = 20;
            font_family = "IosevkaTerm Nerd Font Propo, Bold";
            position = "40, 40";
            halign = "left";
            valign = "top";
            shadow_passes = 5;
            shadow_size = 10;
          }
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
    vscode = {
      enable = true;
    };
    lazydocker.enable = true;
    thunderbird = {
      enable = true;
      profiles = {
        default = {
          isDefault = true;
        };
      };
    };
  };


  services = {
    hyprshell.enable = false;

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
