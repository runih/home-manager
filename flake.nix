{
  description = "Home Manager configuration of runih";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      callHost = path: args:
        let flake = import path;
        in flake.outputs (args // { self = {}; });

      hostArgs = { inherit nixpkgs home-manager; };
    in {
      homeConfigurations = {
        # macOS hosts
        "runih@BlackMac"              = (callHost ./hosts/mac/BlackMac/flake.nix       hostArgs).homeConfigurations.runih;
        "maiken@MaikensMacbook.local" = (callHost ./hosts/mac/MaikensMacbook/flake.nix hostArgs).homeConfigurations.MaikensMacbook;
        "runih@iMac.home.okkara.net"  = (callHost ./hosts/mac/iMac/flake.nix           hostArgs).homeConfigurations.iMac;

        # Linux hosts
        "runih@macnix"         = (callHost ./hosts/linux/macnix/flake.nix        hostArgs).homeConfigurations.macnix;
        "runih@nixos-pi5"      = (callHost ./hosts/linux/nixos-pi5/flake.nix     hostArgs).homeConfigurations.nixos-pi5;
        "minecraft@nixos-pi5"  = (callHost ./hosts/linux/nixos-pi5/flake.nix     hostArgs).homeConfigurations.minecraft;
        "runih@nixos"          = (callHost ./hosts/linux/nixos/flake.nix         hostArgs).homeConfigurations.nixos;
        "runih@nixos2"         = (callHost ./hosts/linux/nixos2/flake.nix        hostArgs).homeConfigurations.nixos2;
        "runih@madakara-nixos" = (callHost ./hosts/linux/madakara-nixos/flake.nix hostArgs).homeConfigurations.madakara-nixos;
      };
    };
}
