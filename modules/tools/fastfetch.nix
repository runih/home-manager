{ lib, ... }:
{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        padding = { top = 1; };
      };
      display = {
        separator = " → ";
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "localip"
        "break"
        "colors"
      ];
    };
  };

  # Print system info once per interactive terminal session. The exported
  # marker means opening a subshell / running `zsh` by hand stays quiet;
  # a fresh terminal window starts with a clean env and shows it again.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    if [[ -o interactive && -z ''${FASTFETCH_SHOWN:-} ]]; then
      export FASTFETCH_SHOWN=1
      fastfetch
    fi
  '';
}
