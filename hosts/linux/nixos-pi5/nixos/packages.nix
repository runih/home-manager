{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bc
    btop
    btrfs-progs
    ethtool
    fastfetch
    git
    home-manager
    htop-vim
    iptraf-ng
    iw              # wifi diagnostics (wld0 is this host's uplink)
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
