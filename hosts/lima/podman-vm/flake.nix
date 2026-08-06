{
  description = "NixOS Lima VM with Podman — runih@BlackMac";

  inputs = {
    nixos-lima.url = "github:ciderale/nixos-lima";
    nixpkgs.follows = "nixos-lima/nixpkgs";
  };

  outputs = { self, nixos-lima, nixpkgs }:
    let
      vmName      = "podman-vm";
      guestSystem = "aarch64-linux";
      hostSystem  = "aarch64-darwin";
    in {
      nixosConfigurations.${vmName} = nixpkgs.lib.nixosSystem {
        system = guestSystem;
        specialArgs = { inherit (nixos-lima) nixosModules; };
        modules = [
          nixos-lima.nixosModules.lima
          nixos-lima.nixosModules.disk-default
          nixos-lima.nixosModules.impure-config
          nixos-lima.nixosModules.lima-container
          ./lima-settings.nix
          ./configuration.nix
        ];
      };

      # `nix run .#podman-vm start|stop|ssh|...`
      apps.${hostSystem}.${vmName} = {
        type = "app";
        program =
          let
            pkgs        = import nixpkgs { system = hostSystem; };
            nixos-lima-bin = nixos-lima.packages.${hostSystem}.nixos-lima;
            app = pkgs.writeShellApplication {
              name = vmName;
              runtimeInputs = [ nixos-lima-bin ];
              text = ''nixos-lima "${self}#${vmName}" "''${@}"'';
            };
          in "${app}/bin/${vmName}";
      };
    };
}
