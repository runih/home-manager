#!/usr/bin/env bash
# Clear any stale /etc/nixos/configuration.nix or /etc/nixos/flake.nix so
# nobody accidentally rebuilds from the unpinned classic path or a broken
# shim. The real system config lives in this checkout and flake.lock pins
# nixpkgs to nixos-26.05 (matching home-manager) — always rebuild with:
#
#   sudo nixos-rebuild switch --flake <this-dir>#nixos-pi5
#
# (aliased to `nixos-switch` via hosts/linux/nixos-pi5/home.nix). A flake.nix
# at /etc/nixos can't just `import` this repo's flake.nix — nix's flake
# front end needs a literal attribute set at the top of flake.nix to read
# `inputs` before evaluation, so that indirection fails with "must be an
# attribute set". Explicit --flake avoids the problem entirely.
#
# The old modular classic config (boot.nix, networking.nix, ...) that used
# to live in /etc/nixos is now mirrored here; run this once to drop the
# stale copies so /etc/nixos stops being a second source of truth.
set -euo pipefail

sudo rm -f /etc/nixos/configuration.nix /etc/nixos/flake.nix /etc/nixos/flake.lock \
  /etc/nixos/hardware-configuration.nix /etc/nixos/boot.nix /etc/nixos/console.nix \
  /etc/nixos/docker.nix /etc/nixos/networking.nix /etc/nixos/packages.nix \
  /etc/nixos/programs.nix /etc/nixos/services.nix /etc/nixos/users.nix \
  /etc/nixos/security.nix /etc/nixos/raspberry-pi5-leds.nix /etc/nixos/bluetooth.nix

echo "Cleared /etc/nixos. Rebuild with: nixos-switch (after running hm to pick up the alias)"
