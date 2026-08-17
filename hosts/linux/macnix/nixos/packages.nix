{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    vim
    # VA-API hardware video decode is off by default for Chromium on Linux;
    # this iGPU (Intel HD 615) supports H264/HEVC/VP9 decode in hardware.
    (vivaldi.override {
      commandLineArgs = "--ozone-platform=wayland --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoDecoder";
    })
    python313
    sof-firmware
    xkeyboard_config
    audit # auditctl/auditd/ausearch, for testing the kernel audit subsystem
  ];
}
