{ pkgs, ... }:
let
  my-tmux-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "simple-tmux";
    rev = "78c7c3b2bc154f5762c0e5192d93d946250da5a0";
    hash = "sha256-CVzgxfBSNrz2pE4+YRvbt4jizrEwRUJIMjhQs23+/Ow=";
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
