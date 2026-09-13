{ pkgs, lib, config, ... }:

let
  kernelPackages = config.boot.kernelPackages;
  facetimehdPkg = kernelPackages.facetimehd.overrideAttrs (old: {
    version = "0.7.2";
    src = pkgs.fetchFromGitHub {
      owner = "patjak";
      repo = "facetimehd";
      rev = "0.7.2";
      hash = "sha256-l0bmbkjjqjTXpyAAP7jAxSafg9kQgv2BmK7Oki5n0Iw=";
    };
    postPatch = ''
      sed -i 's/#include "fthd_isp.h"/#include "fthd_isp.h"\n#include <linux\/string.h>/' fthd_v4l2.c
    '';
  });
  firmwareDir = "${pkgs.facetimehd-firmware}/lib/firmware";
in
{
  nixpkgs.config.allowUnfree = true;

  # This MacBook's built-in camera is a Broadcom 720p FaceTime HD Camera on
  # PCIe (`lspci`: "03:00.0 Multimedia controller [0480]: Broadcom Inc. and
  # subsidiaries 720p FaceTime HD Camera [14e4:1570]"), which has no
  # in-tree Linux driver and shows up with no /dev/video* node and no
  # kernel driver bound. NixOS ships an out-of-tree module (the community
  # `bcwc_pcie`/facetimehd driver) plus the proprietary sensor firmware
  # extracted from macOS; this option builds/loads both, blacklists the
  # conflicting in-tree `bdc_pci` stub, and adds suspend/resume hooks
  # (the module crashes the whole system if left loaded across sleep).
  hardware.facetimehd.enable = true;

  # nixpkgs pins facetimehd to upstream tag 0.7.0.2, which predates the
  # driver's kernel-7.x compatibility work (the `struct vb2_ops`
  # wait_prepare/wait_finish members it references were dropped from
  # videobuf2 core; upstream's fix is a `#if LINUX_VERSION_CODE <
  # KERNEL_VERSION(7, 0, 0)` guard added after that tag was cut). Build
  # fails on this kernel with "'vb2_ops_wait_finish' undeclared". Override
  # the package to the current 0.7.2 tag, which has that guard.
  boot.extraModulePackages = lib.mkForce [ facetimehdPkg ];

   # The NixOS activation script sets firmware_class.parameters.path but
   # does not create /lib/firmware as a symlink. Without it the kernel
   # cannot find the firmware at the standard path.
   system.activationScripts.facetimehd-firmware.text = ''
     mkdir -p /lib/firmware
     ln -sf ${firmwareDir} /lib/firmware
   '';

   # The kernel's firmware_class module parameter is baked into the
   # initramfs/boot config and points to the old firmware store path
   # (which no longer exists after nixos-switch). We override it here
   # so the kernel looks at the correct facetimehd-firmware directory
   # on the next boot.
   boot.kernelParams = [ "firmware_class.path=${firmwareDir}" ];
}
