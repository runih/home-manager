{ pkgs, ... }:
let
my-tmux-config = pkgs.fetchFromGitHub {
  owner = "runih";
  repo = "simple-tmux";
  rev = "666cb10c8603ca157622c33da83bf670148319ff";
  hash = "sha256-XUZQPe+TuB5MGq6LyefPERrdbyXWbbOwx6bem5lNvfE=";
};
my-tmux-config-with-shell = pkgs.runCommand "simple-tmux-config-with-shell" {} ''
  mkdir -p $out
  cp -r ${my-tmux-config}/. $out/
  chmod -R u+w $out
  cat >> $out/tmux.conf << EOF

# Use the home-manager-managed zsh as the default shell for new panes/windows,
# since the system login shell (/etc/passwd) isn't always zsh.
set-option -g default-shell "${pkgs.zsh}/bin/zsh"

# Terminal window title and tmux window name: relay whatever title the
# running program sets (e.g. Claude Code's animated status), falling back
# to the current process when nothing has set one. pane_title defaults to
# the hostname until a program sets it via an OSC title escape sequence,
# so compare against that to detect the "untouched" case.
set-option -g set-titles on
set-option -g set-titles-string "#{session_name}: #{?#{==:#{pane_title},#{host_short}},#{pane_current_command},#{pane_title}}"
set-option -g automatic-rename on
set-option -g automatic-rename-format "#{?#{==:#{pane_title},#{host_short}},#{pane_current_command},#{pane_title}}"
EOF
'';
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
    source = my-tmux-config-with-shell;
    recursive = true;
  };
}
