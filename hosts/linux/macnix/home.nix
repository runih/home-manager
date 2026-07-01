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
      wlogout         # Wayland logout screen
      wofi            # Application launcher for Wayland
    ];

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
}
