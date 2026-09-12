{ ... }:

{
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
nixpkgs.overlays = [
     (final: prev: {
       linuxPackages = prev.linuxPackages // {
         facetimehd = prev.linuxPackages.facetimehd.overrideAttrs (old: {
           version = "0.7.2";
           src = final.fetchFromGitHub {
             owner = "patjak";
             repo = "facetimehd";
             rev = "0.7.2";
             hash = "sha256-l0bmbkjjqjTXpyAAP7jAxSafg9kQgv2BmK7Oki5n0Iw=";
           };
           postPatch = ''
             substituteInPlace fthd_v4l2.c \
               --subst-by-line '#include "fthd_isp.h"' \
               '#include "fthd_isp.h"\n#include <string.h>'
           '';
         });
       };
     })
   ];
}
