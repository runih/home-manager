{ pkgs, ... }:
let
my-tmux-config = pkgs.fetchFromGitHub {
  owner = "runih";
  repo = "simple-tmux";
  rev = "666cb10c8603ca157622c33da83bf670148319ff";
  hash = "sha256-XUZQPe+TuB5MGq6LyefPERrdbyXWbbOwx6bem5lNvfE=";
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
    source = my-tmux-config;
    recursive = true;
  };
}
