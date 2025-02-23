{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    #prefix = "C-Space";
    mouse = true;
    #shell = "${pkgs.zsh}/bin/zsh";
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 10;

    plugins = with pkgs.tmuxPlugins; [
      # tmuxPlugins.tokyo-night-tmux
      # tmux-thumbs
      # cpu
      vim-tmux-navigator
      better-mouse-mode
      sensible
      yank
      {
        plugin = power-theme;
        extraConfig = ''
           set -g @tmux_power_theme 'gold'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          # set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          # set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];

    extraConfig = ''
      # ${pkgs.zsh}
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      set-window-option -g mode-keys vi

      # Unbinding
      unbind C-b
      unbind %
      unbind '"'
      unbind r
      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode when dragging with mouse

      # Bind Keys
      bind-key C-Space send-prefix
      bind | split-window -h 
      bind - split-window -v
      bind r source-file ~/.config/tmux/tmux.conf

      # Resize Pane
      bind j resize-pane -D 5
      bind k resize-pane -U 5
      bind l resize-pane -R 5
      bind h resize-pane -L 5
      bind -r m resize-pane -Z

      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

      # # For Yazi
      # set -g allow-passthrough all
      # set -ga update-environment TERM
      # set -ga update-environment TERM_PROGRAM
    '';
  };
}
