{ pkgs, ... }:
let
  my-tmux-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "my-tmux-config";
    rev = "866bcaa0f38b05804c07ba3a012b0ff56c8451c1";
    hash = "sha256-vdGt9tTi6zQ1VDaydH0n4uIH+THgfZv6k102WV8YJeA=";
  };
  my-tmux-config-with-titles = pkgs.runCommand "my-tmux-config-with-titles" {} ''
    mkdir -p $out
    cp -r ${my-tmux-config}/. $out/
    cat >> $out/tmux.conf << 'EOF'

# Terminal window title: show session and current window/program
set-option -g set-titles on
set-option -g set-titles-string "#{session_name}: #{window_name}"

# Claude Code / TUI optimizations
set -sg escape-time 0
set -g history-limit 50000
set -g focus-events on
set -g allow-passthrough on
EOF
  '';
  tpm = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    hash = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
  };
in
  {
  home = {
    packages = with pkgs; [
      bc
    ];
    file."bin/tmux-session-name" = {
      text = ''
        #!/usr/bin/env bash
        tmux display-message -p '#S'
      '';
      executable = true;
    };
    file."bin/tmux-window-name" = {
      text = ''
        #!/usr/bin/env bash
        tmux display-message -p '#W'
      '';
      executable = true;
    };
  };
  programs.tmux = {
    enable = true;
  };

  xdg.configFile.tmux = {
    source = my-tmux-config-with-titles;
    recursive = true;
  };
  xdg.configFile."tmux/plugins/tpm" = {
    source = tpm;
    recursive = true;
  };
}
