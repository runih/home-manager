{ pkgs, ... }:
let
  my-tmux-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "simple-tmux";
    rev = "6f4eefa425ddca82487d6dbcfb4dfc937bc01431";
    hash = "sha256-dBT0KNC1hXfGRNhvQeAnl5B+OUREeZuHv5lbd5aDlLk=";
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
