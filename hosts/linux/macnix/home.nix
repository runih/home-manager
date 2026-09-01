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
      "${homeDirectory}/bin"
      "${homeDirectory}/.local/bin"
    ];

    # Specify the state version for compatibility
    stateVersion = "26.05";

    # List of packages to be installed for the user
    packages = with pkgs; [
      aichat          # Terminal client for GPT-4, Gemini, Ollama and other LLMs
      alsa-utils      # Utilities for ALSA sound system
      atlauncher      # Minecraft launcher
      bash            # GNU Bourne-Again Shell
      bat             # A cat clone with syntax highlighting
      bc              # An arbitrary precision calculator language
      blueman         # Bluetooth manager
      bluetuith       # Bluetooth TUI
      btop            # Resource monitor
      dnsutils        # Utilities for querying DNS servers
      fastfetch       # A fast system information tool
      fd              # A simple, fast and user-friendly alternative to find
      file            # Determine file types
      gcc             # GNU Compiler Collection
      git             # Version control system
      github-copilot-cli # GitHub Copilot CLI
      jq              # Command-line JSON processor
      gimp            # GNU Image Manipulation Program
      gnumake         # Build automation tool
      libreoffice     # Office productivity suite
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
      rofi-network-manager # Rofi-based wifi/ethernet connection picker
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
      wl-clipboard    # Wayland clipboard utilities (wl-copy, wl-paste)
      awww            # Wallpaper daemon for Wayland (swww)
      brightnessctl   # Screen/keyboard backlight control
      hyprlock        # Lock screen for Hyprland
      wlogout         # Wayland logout screen
      wofi            # Application launcher for Wayland
    ];

    # Force zen-beta to use VA-API hardware video decode and skip AV1 (this
    # Kaby Lake iGPU has no AV1 decode block, so it'd fall back to slow
    # software decode) in favor of VP9, which is hardware-accelerated.
    # NOTE: targets the existing profile dir by its randomly-generated name
    # (see ~/.config/zen/profiles.ini) — won't apply to a freshly created
    # profile without updating this path.
    file.".config/zen/dwdoa3o0.Default Profile/user.js".text = ''
      user_pref("media.hardware-video-decoding.force-enabled", true);
      user_pref("media.ffmpeg.vaapi.enabled", true);
      user_pref("media.av1.enabled", false);
    '';

    file.".config/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf".text = ''
      monitor.alsa.rules = [
        {
          matches = [ { device.name = "alsa_card.pci-0000_00_1f.3" } ]
          actions = { update-props = { api.alsa.soft-mixer = true } }
        }
      ]
    '';

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

    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };

    # Configuration for the vim program (text editor)
    vim = {
      enable = true;                  # Enable vim
    };

    # System rebuild always via explicit --flake path, not a bare
    # `nixos-rebuild switch` — a shim flake.nix under /etc/nixos can't
    # just `import` this repo's flake.nix (nix's flake front end needs a
    # literal attrset at the top of flake.nix to statically read `inputs`
    # before evaluation, so an indirection like that fails with
    # "must be an attribute set"). Same pattern as the `hm` alias.
    zsh.shellAliases = {
      nixos-switch = "sudo nixos-rebuild switch --flake ${homeDirectory}/.config/home-manager/hosts/linux/macnix/nixos#macnix";
    };
  };
}
