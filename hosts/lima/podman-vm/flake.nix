{
  description = "NixOS Lima VM with Podman — runih@BlackMac";

  inputs = {
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-26.05";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-lima provides the Lima NixOS modules (guestagent, CIDATA mount, etc.)
    nixos-lima.url = "github:ciderale/nixos-lima";
    nixos-lima.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-generators, nixos-lima, ... }:
    let
      vmName      = "podman-vm";
      guestSystem = "aarch64-linux";
      hostSystem  = "aarch64-darwin";
    in {
      # Build the NixOS QCOW2 image.
      # Requires an aarch64-linux builder (macnix or nixos-pi5):
      #   nix build .#packages.aarch64-linux.default --print-out-paths
      packages.${guestSystem}.default = nixos-generators.nixosGenerate {
        system  = guestSystem;
        format  = "qcow-efi";
        modules = [
          nixos-lima.nixosModules.lima
          ./lima-settings.nix
          ./configuration.nix
        ];
      };
    };
}
