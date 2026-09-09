{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./boot.nix
      ./console.nix
      ./docker.nix
      ./networking.nix
      ./packages.nix
      ./programs.nix
      ./services.nix
      ./tuning.nix
      ./users.nix
      ./security.nix
      ./raspberry-pi5-leds.nix
      ./bluetooth.nix
      ./tryboot.nix
    ];

  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # zsh-autoenv (programs.nix) is marked unfree as of nixos-26.05.
  nixpkgs.config.allowUnfree = true;
  system = {
    stateVersion = "25.11"; # Did you read the comment?
  };
}
