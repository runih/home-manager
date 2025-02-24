{ pkgs, ... }:
let
  my-tmux-config = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "my-tmux-config";
    rev = "866bcaa0f38b05804c07ba3a012b0ff56c8451c1";
    hash = "sha256-vdGt9tTi6zQ1VDaydH0n4uIH+THgfZv6k102WV8YJeA=";
  };
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
  };
  programs.tmux = {
    enable = true;
  };

  xdg.configFile.tmux = {
    source = my-tmux-config;
    recursive = true;
  };
  xdg.configFile."tmux/plugins/tpm" = {
    source = tpm;
    recursive = true;
  };
}
