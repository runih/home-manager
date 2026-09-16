{ pkgs, ... }:

{
  # zram: compressed RAM swap, tried before the on-disk swap partition
  # from hardware-configuration.nix (NixOS gives zram swap priority 5;
  # the disk swapDevices entry keeps its default lower priority and only
  # takes overflow once zram is full). Same pattern as nixos-pi5's
  # tuning.nix — cuts down on disk swap I/O/battery/SSD wear under memory
  # pressure on this 8/16GB laptop.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # One-shot runtime power-management tuning (USB autosuspend, PCIe ASPM,
  # audio codec power saving, etc.) equivalent to `powertop --auto-tune`.
  # power-profiles-daemon only manages CPU governor/EPP; it doesn't touch
  # any of this, so this is genuinely additive rather than overlapping.
  systemd.services.powertop-auto-tune = {
    description = "powertop --auto-tune";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
    };
  };

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

    # Display/login manager + GNOME session live in ./login-manager.nix
    # (greetd+tuigreet vs GDM toggle).

    # Enable the X11 windowing system (kept for xkb extraLayouts /
    # XKB_CONFIG_ROOT even though sessions are Wayland). Keymap config
    # (console.keyMap, xserver.xkb, custom XKB symbol file) lives in
    # keyboard.nix.
    xserver.enable = true;
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

    # Periodic TRIM for the SSD-backed root/boot filesystems. NixOS does
    # not enable this by default and no `discard` mount option is set in
    # hardware-configuration.nix, so without this the drive was never
    # being TRIMmed.
    fstrim.enable = true;
  };
}
