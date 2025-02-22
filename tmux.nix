{ pkgs, ... }:
let
  tpm = pkgs.tmuxPlugins.mkTmuxPlugin 
  {
    pluginName = "tpm";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
      hash = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
    };
  };
  tmux-sensible = pkgs.tmuxPlugins.mkTmuxPlugin 
  {
    pluginName = "tmux-sensible";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-sensible";
      rev = "25cb91f42d020f675bb0a2ce3fbd3a5d96119efa";
      hash = "sha256-sw9g1Yzmv2fdZFLJSGhx1tatQ+TtjDYNZI5uny0+5Hg=";
    };
  };
  vim-tmux-navigator = pkgs.tmuxPlugins.mkTmuxPlugin 
  {
    pluginName = "vim-tmux-navigator";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "christoomey";
      repo = "vim-tmux-navigator";
      rev = "d847ea942a5bb4d4fab6efebc9f30d787fd96e65";
      hash = "sha256-EkuAlK7RSmyrRk3RKhyuhqKtrrEVJkkuOIPmzLHw2/0=";
    };
  };
  tmux-fzf = pkgs.tmuxPlugins.mkTmuxPlugin 
  {
    pluginName = "tmux-fzf";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "sainnhe";
      repo = "tmux-fzf";
      rev = "1547f18083ead1b235680aa5f98427ccaf5beb21";
      hash = "sha256-dMqvr97EgtAm47cfYXRvxABPkDbpS0qHgsNXRVfa0IM=";
    };
  };
  tmux-themepack = pkgs.tmuxPlugins.mkTmuxPlugin 
  {
    pluginName = "tmux-themepack";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "jimeh";
      repo = "tmux-themepack";
      rev = "7c59902f64dcd7ea356e891274b21144d1ea5948";
      hash = "sha256-c5EGBrKcrqHWTKpCEhxYfxPeERFrbTuDfcQhsUAbic4=";
    };
  };
in
  {
    programs.tmux = {
      enable = true;
    #shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      tpm
      tmux-sensible
      vim-tmux-navigator
      tmux-fzf
      {
        plugin = tmux-themepack;
        extraConfig = "set -g @themepack 'powerline/default/cyan'";
      }
    ];

    extraConfig = ''
    set -g default-terminal "screen-256color"
    set-option -sa terminal-overrides ",xterm*:Tc"

    # set-option -g default-shell /bin/zsh


    # Start windows and panes at 1, not  0
    set -g base-index 1
    set -g pane-base-index 1
    set-window-option -g pane-base-index 1
    set-option -g renumber-windows on

    # set -g prefix C-a
    # unbind C-b
    # bind-key C-a send-prefix

    unbind %
    bind | split-window -h -c "#{pane_current_path}"

    unbind '"'
    bind - split-window -v -c "#{pane_current_path}"

    unbind r
    bind r source-file ~/.config/tmux/tmux.conf

    bind-key s set-window-option synchronize-pane
    bind-key H select-layout even-horizontal
    bind-key V select-layout even-vertical

    if-shell '[ $(echo "$(tmux -V | sed "s/^tmux \([0-9.]*\).*/\1/") >= 3.2" | bc) -eq 1 ]' \
      'bind-key N { display-popup -h 3 -E "~/.config/tmux/new-session.sh" }'

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      set -g mouse on

      set-window-option -g mode-keys vi

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      unbind -T copy-mode-vi MouseDragEnd1Pane

      # tpm plugin
      set -g @plugin 'tmux-pluigns/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'

      # list of tmux plugins
      # run: git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'jimeh/tmux-themepack'
      set -g @plugin 'sainnhe/tmux-fzf'


      set -g @themepack 'powerline/default/cyan'

      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'

    '';
  };
}

