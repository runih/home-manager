{ pkgs, ... }:

{
  # Bootloader.
  boot = {
    # Stay up-to-date with the latest Linux kernel.
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
      # Intel HD 615: framebuffer compression + panel self-refresh (Retina battery saving)
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
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
