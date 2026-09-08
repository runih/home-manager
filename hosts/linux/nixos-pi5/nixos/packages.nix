{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bc
    btop
    btrfs-progs
    fastfetch
    git
    home-manager
    htop-vim
    iptraf-ng
    nmon
    pciutils
    raspberrypi-eeprom
    tmux
    unzip
    usbutils
    vim
    wget
  ];
}
