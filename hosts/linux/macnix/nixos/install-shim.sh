#!/usr/bin/env bash
# Write /etc/nixos/configuration.nix as a one-line shim that imports this
# checkout's configuration.nix, so `sudo nixos-rebuild switch` on macnix
# always builds from here without any copying step.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/etc/nixos/configuration.nix"

sudo tee "$TARGET" > /dev/null <<EOF
# The real system configuration for this machine (macnix) lives in the
# home-manager git repo, which is backed up to a remote — /etc/nixos itself
# has no remote configured. This file only exists so nixos-rebuild has an
# entry point; edit hosts/linux/macnix/nixos/configuration.nix instead.
import $SCRIPT_DIR/configuration.nix
EOF

echo "Wrote $TARGET"
