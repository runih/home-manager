{ pkgs, username, homeDirectory, ... }:

{
  home = {
    # Define the username for the home configuration
    username = "${username}";

    # Specify the home directory path
    homeDirectory = "${homeDirectory}";

    # Set the default editor for the session
    sessionVariables = {
      EDITOR = "nvim";
      PG_PASS = "${homeDirectory}/.pgpass";
      PG_NETWORK = "docker_my_network";
      PG_HISTORY = "${homeDirectory}/.psql_history";
      FZF_DEFAULT_OPTS = "--bind=ctrl-j:down,ctrl-k:up";
    };
    # Add custom paths to the session's PATH environment variable
    sessionPath = [
      "${homeDirectory}/.nix-profile/bin"
    ];

    # Specify the state version for compatibility
    stateVersion = "26.05";

    # List of packages to be installed for the user
    packages = with pkgs; [
      alsa-utils      # Utilities for ALSA sound system
      atlauncher      # Minecraft launcher
      bat             # A cat clone with syntax highlighting
      bc              # An arbitrary precision calculator language
      blueman         # Bluetooth manager
      bluetuith       # Bluetooth TUI
      btop            # Resource monitor
      claude-code     # Claude AI command-line interface
      dnsutils        # Utilities for querying DNS servers
      fastfetch       # A fast system information tool
      fd              # A simple, fast and user-friendly alternative to find
      file            # Determine file types
      gcc             # GNU Compiler Collection
      git             # Version control system
      jq              # Command-line JSON processor
      gnumake         # Build automation tool
      neovim
      go             # Go programming language
      htop-vim        # Interactive process viewer with vim keybindings
      lazygit         # Simple terminal UI for git commands
      lynx            # Text-based web browser
      minio-client    # Client for MinIO and Amazon S3 compatible cloud storage
      net-tools       # Network configuration tools
      nodejs_22       # JavaScript runtime built on Chrome's V8 engine
      pciutils        # Utilities for listing PCI devices
      pstree          # Display a tree of processes
      ripgrep         # A fast search tool
      rustup          # Rust toolchain installer
      superfile       # (Assumed custom package, no description available)
      teams-for-linux # Unofficial Microsoft Teams client for Linux
      tmux            # Terminal multiplexer
      tree            # Display directories as trees
      unzip           # Extract ZIP archives
      usbutils        # Utilities for USB devices
      virtualenv      # Tool to create isolated Python environments
      w3m             # Text-based web browser
      wget            # Command-line utility for downloading files
      awww            # Wallpaper daemon for Wayland (swww)
      hyprlock        # Lock screen for Hyprland
      wlogout         # Wayland logout screen
      wofi            # Application launcher for Wayland
    ];

    file.".config/wofi/config".text = ''
      allow_images=true
      allow_markup=true
      image_size=20
    '';

    file.".config/wofi/style.css".text = ''
      window {
        background-color: rgba(26, 27, 38, 0.95);
        border: 1px solid #414868;
        border-radius: 8px;
      }

      #input {
        background-color: #1e2030;
        color: #c0caf5;
        border: 1px solid #414868;
        border-radius: 4px;
        padding: 8px 12px;
        margin: 8px;
        font-size: 14px;
      }

      #input:focus {
        border-color: #7aa2f7;
      }

      #scroll {
        margin: 0 8px 8px 8px;
      }

      #inner-box {
        background-color: transparent;
      }

      #outer-box {
        background-color: transparent;
        padding: 4px;
      }

      #entry {
        padding: 6px 10px;
        border-radius: 4px;
        color: #a9b1d6;
      }

      #entry:selected {
        background-color: rgba(122, 162, 247, 0.2);
        color: #c0caf5;
      }

      #text {
        font-size: 13px;
      }

      #img {
        margin-right: 8px;
      }
    '';

    file.".config/hypr/hyprlock.conf".text = ''
      animations {
        enabled = true
        bezier = easeInOut, 0.4, 0, 0.6, 1
        animation = fadeIn, 1, 5, easeInOut
        animation = fadeOut, 1, 5, easeInOut
      }

      background {
        monitor =
        path = $HOME/Pictures/hyprlock/key7.png
      }

      input-field {
        monitor =
        size = 400, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        dots_rounding = -1
        outer_color = rgb(00d4ff)
        inner_color = rbg(FFFFFF)
        font_color = rbg(10, 10, 10)
        fade_on_empty = true
        fade_timeout = 1000
        placeholder_text = <i>Enter Password...</i>
        hide_input = false
        rounding = -1
        check_color = rbg(204, 136, 34)
        fail_color = rbg(204, 34, 34)
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        fail_transition = 300
        capslock_color = -1
        numlock_color = -1
        bothlock_color = -1
        invert_numlock = false
        swap_font_color = false
        position = 0, -20
        halign = center
        valign = center
        shadow_passes = 4
        shadow_size = 10
        shadow_color = rgba(122, 162, 247, 0.8)
        shadow_boost = 1.5
      }

      label {
        monitor =
        text = cmd[update:1000] echo "$(date +'%V')"
        color = rgba(200, 200, 200, 0.1)
        font_size = 250
        font_family = Fira Semibold
        position = -10, 20
        halign = right
        valign = top
        shadow_passes = 5
        shadow_size = 10
      }

      label {
        monitor =
        text = cmd[update:1000] echo "$(date +'%d %B %Y')"
        color = rgba(200, 200, 200, 0.1)
        font_size = 120
        font_family = Fira Semibold
        position = 50, 20
        halign = left
        valign = bottom
        shadow_passes = 5
        shadow_size = 10
      }

      label {
        monitor =
        text = cmd[update:1000] echo "$TIME"
        color = rgba(200, 200, 200, 1.0)
        font_size = 55
        font_family = Fira Semibold
        position = -50, 50
        halign = right
        valign = bottom
        shadow_passes = 5
        shadow_size = 10
      }

      label {
        monitor =
        text = $USER
        color = rgba(200, 200, 200, 1.0)
        font_size = 20
        font_family = Fira Semibold
        position = -50, 150
        halign = right
        valign = bottom
        shadow_passes = 5
        shadow_size = 10
      }

      label {
        monitor =
        text = cmd[update:60000] cat $HOME/.cache/weather 2>/dev/null || echo "N/A"
        color = rgba(200, 200, 200, 0.1)
        font_size = 60
        font_family = Fira Semibold
        position = 50, -50
        halign = left
        valign = top
        shadow_passes = 5
        shadow_size = 10
      }
    '';

    file."Pictures/hyprlock/key7.png".source = ./hyprlock/key7.png;

    file."bin/change_wallpaper" = {
      text = ''
        #!/usr/bin/env bash
        WALLPAPER_DIR="$HOME/Pictures/wallpapers"
        if [ "$1" = "--random" ]; then
          wall=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n1)
        elif [ -n "$1" ]; then
          wall="$1"
        else
          wall=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n1)
        fi
        swww img "$wall" --transition-type wipe --transition-duration 1
      '';
      executable = true;
    };

    file."bin/battery-status" = {
      text = ''
      #!/usr/bin/env bash
      BAT='/sys/class/power_supply/BAT0'
      status=$(cat $BAT/status)
      if [ "$status" = "Full" ]; then
        status="Charged"
        capacity=100
      else
        charge_now=$(cat $BAT/charge_now)
        charge_full=$(cat $BAT/charge_full)
        capacity=$(($charge_now * 100 / $charge_full))
        if [ $capacity -gt 100 ]; then
          capacity=100
        fi
      fi
      bar_length=30
      filled=$((capacity * bar_length / 100))
      empty=$((bar_length - filled))

      printf "$status: ["
      for ((i=0; i<filled; i++)); do printf "█"; done
      for ((i=0; i<empty; i++)); do printf "▒"; done
      printf "] %s%%\n" "$capacity"
      '';
      executable = true;
    };
    file."bin/fetch-weather" = {
      text = ''
        #!/usr/bin/env bash
        mkdir -p "$HOME/.cache"
        result=$(${pkgs.curl}/bin/curl -sf --max-time 10 "wttr.in/?format=%c%20%C%20%t" 2>/dev/null)
        if [ -n "$result" ]; then
          echo "$result" > "$HOME/.cache/weather"
        elif [ ! -f "$HOME/.cache/weather" ]; then
          echo "N/A" > "$HOME/.cache/weather"
        fi
      '';
      executable = true;
    };

    file."bin/current-load" = {
      text = ''
      #!/usr/bin/env bash
      load=$(cut -f1 -d' ' /proc/loadavg)
      cores=$(nproc)
      percent=$(echo "$load $cores" | awk '{printf "%d", ($1 / $2) * 100}')

      bar_length=60
      if [ "$1" != "" ]; then
          bar_length=$1
      fi
      filled=$((percent * bar_length / 100))
      empty=$((bar_length - filled))

      printf "["
      for ((i=0; i<filled; i++)); do printf "█"; done
      for ((i=0; i<empty; i++)); do printf "▒"; done
      printf "]\n"
      '';
      executable = true;
    };
  };

  accounts.email.accounts = {
    "Okkara.NET" = {
      thunderbird = {
        enable = true;
        profiles = [ "default"  ];
      };
      primary = true;
      realName = "Rúni H.Hansen";
      address = "runi.hansen@okkara.net";
      userName = "runi.hansen@okkara.net";
      imap = {
        host = "imap.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
      smtp = {
        host = "smtp.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
    };
    "Admin" = {
      thunderbird = {
        enable = true;
        profiles = [ "default"  ];
      };
      primary = false;
      realName = "Admin";
      address = "admin@okkara.net";
      userName = "admin@okkara.net";
      imap = {
        host = "imap.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
      smtp = {
        host = "smtp.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
    };
    "Tango" = {
      thunderbird = {
        enable = true;
        profiles = [ "default"  ];
      };
      primary = false;
      realName = "Tango";
      address = "tango@okkara.net";
      userName = "tango@okkara.net";
      imap = {
        host = "imap.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
      smtp = {
        host = "smtp.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
    };
    "wilix" = {
      thunderbird = {
        enable = true;
        profiles = [ "default"  ];
      };
      primary = false;
      realName = "Rúni H.Hansen";
      address = "runi.hansen@wilix.com";
      userName = "runi.hansen@wilix.com";
      imap = {
        host = "imap.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
      smtp = {
        host = "smtp.websupport.se";
        tls = {
          useStartTls = true;
        };
      };
    };
  };

  programs = {
    # Enable home-manager for managing user configurations
    home-manager.enable = true;

    # caelestia.enable = true; # Enable Caelestia, a terminal-based system monitor


    # Configuration for the eza program (modern ls replacement)
    eza = {
      enable = true;                  # Enable eza
      enableZshIntegration = true;    # Enable Zsh integration
      git = true;                     # Enable Git support
      icons = "auto";                 # Automatically enable icons
    };

    # Configuration for the fzf program (fuzzy finder)
    fzf = {
      enable = true;                  # Enable fzf
      enableZshIntegration = true;    # Enable Zsh integration
    };

    # Configuration for the oh-my-posh program (prompt theme engine)
    oh-my-posh = {
      enable = true;                  # Enable oh-my-posh
      enableZshIntegration = true;    # Enable Zsh integration
      useTheme = "blue-owl";             # Set the theme to "sorin"
    };

    # Configuration for the vim program (text editor)
    vim = {
      enable = true;                  # Enable vim
    };
  };

  systemd.user.services.weather-fetch = {
    Unit.Description = "Fetch weather from wttr.in";
    Service = {
      Type = "oneshot";
      ExecStart = "${homeDirectory}/bin/fetch-weather";
    };
  };

  systemd.user.timers.weather-fetch = {
    Unit.Description = "Weather fetch timer";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30min";
      Unit = "weather-fetch.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
