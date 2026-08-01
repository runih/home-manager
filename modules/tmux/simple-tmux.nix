{ pkgs, lib, config, ... }:
let
my-tmux-config = pkgs.fetchFromGitHub {
  owner = "runih";
  repo = "simple-tmux";
  rev = "666cb10c8603ca157622c33da83bf670148319ff";
  hash = "sha256-XUZQPe+TuB5MGq6LyefPERrdbyXWbbOwx6bem5lNvfE=";
};
batteryTmuxConf = ''

# Battery percentage in status-right, prepended to the existing line from
# tmux.conf. The script embeds its own #[...] colour codes (tmux re-parses
# those out of job output), so a low status-interval is needed for the
# low-battery flash to be visible.
set-option -g status-interval 1
set-option -g status-right "#{?#{!=:#(\$HOME/bin/tmux-battery),},#(\$HOME/bin/tmux-battery) #[default],}#[fg=cyan]#(id -un)@#[fg=brightmagenta]#H #[fg=red][#[fg=yellow]#([ -f /proc/loadavg ] && cut -d' ' -f1,2,3 /proc/loadavg || echo \"loadavg is missing\")#{?@show_time,#[fg=red]|#[fg=cyan]%H:%M,}#[fg=red]]#[default]"
'';
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
${lib.optionalString config.host.hasBattery batteryTmuxConf}
EOF
'';
in
  {
  options.host.hasBattery = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether this host has a battery. Enables a battery indicator (percentage, charging/plugged/on-battery icon, low-battery flash) in the tmux status line.";
  };

  config = {
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
    file."bin/tmux-battery" = {
      text = ''
        #!/usr/bin/env bash
        # BAT0/capacity is unreliable on this machine (conservation mode
        # reports "Full" well below 100%), so compute the percentage from
        # the raw charge counters instead.
        now=/sys/class/power_supply/BAT0/charge_now
        full=/sys/class/power_supply/BAT0/charge_full
        online=/sys/class/power_supply/ADP1/online
        status=/sys/class/power_supply/BAT0/status
        if [ -f "$now" ] && [ -f "$full" ]; then
          pct=$(( $(cat "$now") * 100 / $(cat "$full") ))
          if [ "$(cat "$online" 2>/dev/null)" = "1" ]; then
            if [ "$(cat "$status" 2>/dev/null)" = "Charging" ]; then
              icon="⚡"
            else
              icon="🔌"
            fi
            echo "#[fg=green]$pct% $icon"
          elif [ "$pct" -lt 10 ]; then
            # Blinking text (#[blink]) isn't rendered by every terminal, so
            # flash by alternating the foreground colour every second
            # instead - relies on status-interval being low enough to
            # actually redraw that often.
            sec=$(date +%S)
            if (( 10#$sec % 2 == 0 )); then
              echo "#[fg=red]$pct% ⚠"
            else
              echo "#[fg=default]$pct% ⚠"
            fi
          else
            echo "#[fg=green]$pct% 🔋"
          fi
        fi
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
  };
}
