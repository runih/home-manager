{  pkgs, ... }:

{
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "runih";
    homeDirectory = "/Users/runih";
    sessionPath = [
      "/Users/runih/.nix-profile/bin"
    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      bat
      bc
      binutils
      btop
      dig
      git
      gnupg1
      go
      htop-vim
      lazygit
      libjpeg
      neovim
      ninja
      nodejs_22
      pass
      pstree
      rustup
      tmux
      tree
      unzip
      vim
      w3m
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/runih/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
    };

  };
  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    ghostty = {
      enable = false;
      settings = {
        window-padding-color = "background";
        theme = "Dark Pastel";
        background-opacity = "0.75";
        macos-titlebar-style = "hidden";
        cursor-color = "#ffff00";
        cursor-style-blink = true;
        adjust-cursor-height = "30%";
        font-family = "Iosevka Nerd Font Mono";
        font-size = 18;
        keybind = "global:shift+cmd+space=toggle_quick_terminal";
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "sorin";
    };
    zsh = {
      enable = true;
      shellAliases = {
        cd = "z";
        cdi = "zi";
      };
    };
    wezterm = {
      enable = false;
      colorSchemes = {
        myTheme = {
          ansi = [
            "#222222" "#D14949" "#48874F" "#AFA75A"
            "#599797" "#8F6089" "#5C9FA8" "#8C8C8C"
          ];
          brights = [
            "#444444" "#FF6D6D" "#89FF95" "#FFF484"
            "#97DDFF" "#FDAAF2" "#85F5DA" "#E9E9E9"
          ];
          background = "#1B1B1B";
          cursor_bg = "#BEAF8A";
          cursor_border = "#BEAF8A";
          cursor_fg = "#1B1B1B";
          foreground = "#BEAF8A";
          selection_bg = "#444444";
          selection_fg = "#E9E9E9";
        };
      };
      enableZshIntegration = true;
      extraConfig = ''
      local config = {
        font_size = 17.0,
        window_decorations = "RESIZE",
        enable_tab_bar = false,
        -- color_scheme = "3024 Night",
        -- color_scheme = "myTheme",
        send_composed_key_when_left_alt_is_pressed = true,
        cursor_blink_rate = 700,
        cursor_blink_ease_in = 'EaseIn',
        cursor_blink_ease_out = 'EaseOut',
        default_cursor_style = 'BlinkingBlock',
        colors = {
          compose_cursor = 'yellow',
          cursor_bg = 'yellow',
          cursor_fg = 'blue',
          cursor_border = 'yellow',
        }
      }
      return config
      '';
    };
    neovide = {
      enable = false;
      settings = {
        fork = true;
        frame = "full";
        idle = true;
        minimized = false;
        neovim-bin = "/homeUsers/runih/.nix-profile/bin/nvim";
        no-multigrid = false;
        srgb = false;
        tabs = true;
        theme = "auto";
        title-hidden = true;
        vsync = true;
        wsl = false;

        font = {
          normal = [ "Iosevka Nerd Font"];
          size = 16.0;
          hinting = "full";
          edging = "antialias";
        };
      };
    };
  };
  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
      pinentryPackage = pkgs.pinentry-curses;
      enableScDaemon = false;
    };
  };
}
