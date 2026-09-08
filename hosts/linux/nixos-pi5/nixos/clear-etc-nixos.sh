#!/usr/bin/env bash
# One-shot: retire /etc/nixos as a source of truth after its config was
# mirrored into this checkout. The system config now lives here and is
# applied with `nixos-switch` (a script from ./tryboot.nix), never a bare
# `sudo nixos-rebuild switch`:
#
#   nixos-switch            # nixos-rebuild boot against .../nixos-pi5/nixos
#                           # + stage the new generation for `reboot "0 tryboot"`
#
# A flake.nix left at /etc/nixos can't just `import` this repo's flake.nix
# (nix's flake front end needs a literal attribute set at the top to read
# `inputs` before evaluation, so that indirection fails with "must be an
# attribute set"), which is why the mirror lives here and is referenced by
# explicit --flake path instead.
#
# This drops the classic module files and vim cruft. /etc/nixos/.git (a
# local repo with no remote) is left in place as a historical record.
set -euo pipefail

sudo rm -f \
  /etc/nixos/configuration.nix /etc/nixos/flake.nix /etc/nixos/flake.lock \
  /etc/nixos/hardware-configuration.nix /etc/nixos/boot.nix /etc/nixos/console.nix \
  /etc/nixos/docker.nix /etc/nixos/networking.nix /etc/nixos/packages.nix \
  /etc/nixos/programs.nix /etc/nixos/services.nix /etc/nixos/users.nix \
  /etc/nixos/security.nix /etc/nixos/raspberry-pi5-leds.nix /etc/nixos/bluetooth.nix \
  /etc/nixos/.configuration.nix.un~ /etc/nixos/.hardware-configuration.nix.un~

sudo tee /etc/nixos/README.md >/dev/null <<'EOF'
# /etc/nixos is not used on this machine

The NixOS system config is mirrored in and applied from:

    ~/.config/home-manager/hosts/linux/nixos-pi5/nixos/

Apply changes with `nixos-switch` (see tryboot.nix there), not
`nixos-rebuild switch`. This directory is kept only for its git history.
EOF

echo "Cleared /etc/nixos. System config now lives in ~/.config/home-manager/hosts/linux/nixos-pi5/nixos/"
