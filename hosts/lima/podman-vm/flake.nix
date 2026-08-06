{
  description = "NixOS Lima VM with Podman — runih@BlackMac";

  inputs = {
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-26.05";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    nixos-lima.url = "github:ciderale/nixos-lima";
    nixos-lima.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-generators, nixos-lima, ... }:
    let
      vmName      = "podman-vm";
      guestSystem = "aarch64-linux";
    in {
      # Used by `lima-podman-start` (nixos-lima) for the one-time bootstrap.
      # nixos-lima SSHes into an Ubuntu VM, runs nixos-anywhere, and installs NixOS.
      # No Linux builder required.
      nixosConfigurations.${vmName} = nixpkgs.lib.nixosSystem {
        system  = guestSystem;
        modules = [
          nixos-lima.nixosModules.lima
          nixos-lima.nixosModules.disk-default
          nixos-lima.nixosModules.impure-config
          nixos-lima.nixosModules.lima-container
          ./lima-settings.nix
          ./configuration.nix
        ];
      };

      # Once the Lima VM is running and configured as a Nix builder,
      # use this target to rebuild the NixOS image without Ubuntu:
      #   nix build .#packages.aarch64-linux.default
      packages.${guestSystem}.default = nixos-generators.nixosGenerate {
        system  = guestSystem;
        format  = "qcow-efi";
        modules = [
          nixos-lima.nixosModules.lima
          nixos-lima.nixosModules.lima-container
          ./lima-settings.nix
          ./configuration.nix
        ];
      };
    };
}
