{
  description = "System configuration for macnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Hyprland (compositor + portal) is pulled from unstable so macnix runs the
    # latest release (0.56.2) instead of the 0.55.4 that nixos-26.05 ships —
    # see programs.nix. Keep this pin in step with the root flake's
    # nixpkgs-unstable, the same way nixpkgs is kept in sync (CLAUDE.md).
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Only evaluated when `enableOmarchy` below is true — see ./omarchy.nix.
    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, omarchy-nix }:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      # System half of the macnix Omarchy toggle. Read ./omarchy.nix and
      # reconcile the listed conflicts before flipping this on, and flip the
      # matching `enableOmarchy` in ../flake.nix (the home-manager half) too.
      enableOmarchy = false;
    in {
      nixosConfigurations.macnix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit omarchy-nix pkgs-unstable; };
        modules = [ ./configuration.nix ]
          ++ nixpkgs.lib.optional enableOmarchy ./omarchy.nix;
      };
    };
}
