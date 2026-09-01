{ pkgs, ... }:

{
  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      # systemd-boot's menu is an unthemeable UEFI text list. Limine (below)
      # lists the same generations but takes a Tokyo Night palette to match
      # Plymouth (hexagon_hud) / hyprlock / omarchy. Flip these two back to
      # revert; only one bootloader may be enabled at a time.
      systemd-boot = {
        enable = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;

      # --- Themed generation picker (Limine) -------------------------------
      # This is a MacBook10,1 (Apple EFI). If a generation won't boot, hold
      # Option at power-on and pick the EFI volume / previous entry; worst
      # case, re-flip systemd-boot on from a live USB and nixos-switch.
      #
      # ./boot-wallpaper.png is generated from ./boot-wallpaper.svg (Tokyo
      # Night hex-HUD, matches Plymouth's hexagon_hud). Regenerate after
      # editing the SVG:
      #   nix-shell -p librsvg --run \
      #     "rsvg-convert -w 1920 -h 1080 -o boot-wallpaper.png boot-wallpaper.svg"
      limine = {
        enable = true;
        maxGenerations = 10;
        # Hide Limine's post-selection "Loading kernel…/module…" lines.
        # (`terse`, not `quiet` — `quiet` also hides the menu until a key
        # is pressed. The menu and any errors still show with `terse`.)
        extraConfig = ''
          terse: yes
        '';
        style = {
          interface = {
            resolution = "1920x1080";
            branding = "macnix";
            brandingColor = "7aa2f7"; # tokyo night blue
            helpHidden = true;
          };
          wallpapers = [ ./boot-wallpaper.png ];
          wallpaperStyle = "stretched";
          graphicalTerminal = {
            # Shrink the menu box so more wallpaper shows. `margin` is the
            # blank border in px around the terminal; `marginGradient` softens
            # its edge. `background` is TTRRGGBB — TT is transparency (00 =
            # opaque, higher = more see-through), so the box tints rather than
            # covers the wallpaper.
            margin = 280;
            marginGradient = 24;
            background = "301a1b26";
            foreground = "c0caf5";
            # black;red;green;brown;blue;magenta;cyan;gray
            palette = "15161e;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;a9b1d6";
            # dark gray;br red;br green;yellow;br blue;br magenta;br cyan;white
            brightPalette = "414868;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;c0caf5";
          };
        };
      };
      # -------------------------------------------------------------------
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
      # Inherit the firmware/Plymouth mode on i915 handoff instead of doing
      # a fresh full modeset — removes the flicker right before the greeter.
      # If the panel ever comes up wrong (offset/squished), drop this and
      # boot the previous generation.
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
