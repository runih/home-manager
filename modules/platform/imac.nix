{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
  ];
  programs = {
    zsh.initContent = ''
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fi
          '';
  };
}
