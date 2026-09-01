{ pkgs, ... }:

{
  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [
      "kvm-intel"
    ];
    # extraModprobeConfig = ''
    #   options snd-intel-dspcfg dsp_driver=1
    # '';
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "video=1920x1080"
      # Keep the framebuffer text console off VT1. greetd/the greeter own
      # VT1; without this, when Plymouth releases the display `fbcon` takes
      # over VT1 and dumps the buffered boot log to the screen right before
      # (and again after) the greeter — the "console text" around the login
      # window. Boot messages still render on VT2–6 if you switch there.
      "fbcon=vc:2-6"
      # Keep the firmware/Plymouth video mode instead of a fresh modeset on
      # i915 init — cuts the mode-transition flash on the way to the greeter.
      "i915.fastboot=1"
      # Intel HD 615: framebuffer compression + panel self-refresh (Retina battery saving)
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
      # MacBook10,1's ACPI S3 (deep) resume path hangs the machine every time
      # (confirmed via journalctl: every past "PM: suspend entry (deep)" is
      # followed by a fresh boot ID, never a resume). s2idle reliably wakes
      # on this hardware where deep sleep doesn't.
      "mem_sleep_default=s2idle"
    ];
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "uas"
        "sd_mod"
      ];
      kernelModules = [ "i915" ];
    };

    plymouth = {
      enable = true;
      #theme = "glow";
      #theme = "spinfinity";
      #theme = "connect";
      theme = "hexagon_hud";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "hexagon_hud" ];
        })
      ];
    };
  };
}
