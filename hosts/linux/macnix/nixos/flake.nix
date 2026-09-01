{
  description = "System configuration for macnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Only evaluated when `enableOmarchy` below is true — see ./omarchy.nix.
    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, omarchy-nix }:
    let
      # System half of the macnix Omarchy toggle. Read ./omarchy.nix and
      # reconcile the listed conflicts before flipping this on, and flip the
      # matching `enableOmarchy` in ../flake.nix (the home-manager half) too.
      enableOmarchy = false;
    in {
      nixosConfigurations.macnix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit omarchy-nix; };
        modules = [ ./configuration.nix ]
          ++ nixpkgs.lib.optional enableOmarchy ./omarchy.nix;
      };
    };
}
