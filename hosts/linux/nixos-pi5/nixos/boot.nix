{ ... }:

{
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot = {
    # Set WiFi regulatory domain for Sweden to prevent brcmfmac chanspec errors on 5 GHz DFS channels
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=SE
      options brcmfmac roamoff=1
    '';

    # nixos-26.05 defaults the initrd to systemd, which pulls tpm-tis/tpm-crb
    # into boot.initrd.availableKernelModules. The linux-rpi kernel doesn't
    # build tpm-crb, so the initrd modules-shrunk step fails with
    # "modprobe: FATAL: Module tpm-crb not found". The Pi has no TPM anyway.
    initrd.systemd.tpm2.enable = false;

    loader = {
      # Kept enabled only so nixos-rebuild has a bootloader installer and so
      # /boot/nixos/ stays populated as a backup kernel store. The Pi 5 firmware
      # boots straight from /boot/config.txt and ignores extlinux.conf entirely
      # — the real boot selection is driven by ./tryboot.nix (nixos-switch +
      # tryboot-commit.service), which owns /boot/config.txt and /boot/tryboot.txt.
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 3;
      };
      grub.enable = false;
    };
    # Enables the generation of /boot/extlinux/extlinux.conf
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.efi.efiSysMountPoint = "/boot/efi";
    # Define on which hard drive you want to install Grub.
    # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  };
}
