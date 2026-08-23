{ pkgs, ... }:

{
  services = {
    # Let members of the "video" group control screen and keyboard
    # backlight brightness without root (needed for brightnessctl /
    # XF86MonBrightness* and keyboard backlight keys to work).
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*kbd_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"

      # Switch to the "performance" power profile whenever the charger is
      # plugged in, and back to "balanced" when it's unplugged.
      SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
      SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
    '';

    openvpn.servers = {
      homeVPN = {
        config = '' config /home/runih/Documents/VPNConfig.ovpn '';
        autoStart = false;
        #authUserPass = {
        #  username = "runih";
        #};
      };
      kyrkanVPN = {
        config = '' config /home/runih/Documents/KyrkanOpenVPN.ovpn '';
        autoStart = false;
      };
    };
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable the X11 windowing system.
    displayManager.gdm.enable = true;
    # Default session offered at the GDM login screen (plain Hyprland, no UWSM).
    displayManager.defaultSession = "hyprland";
    # Enable the GNOME Desktop Environment.
    desktopManager.gnome.enable = true;
    xserver = {
      enable = true;
      # Keymap (console.keyMap, xserver.xkb, and the custom XKB symbol file)
      # lives in keyboard.nix.
    };
    # Enable CUPS to print documents.
    printing.enable = false;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Power management
    power-profiles-daemon.enable = true;
    upower.enable = true;
    thermald.enable = true;
  };
}
