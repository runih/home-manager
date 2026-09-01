{
  description = "Home Manager configuration of runih";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Opinionated Omarchy-style Hyprland desktop (DHH's Omarchy, reimplemented
    # for NixOS). Only consumed by macnix, and only when its `enableOmarchy`
    # toggle is flipped on — otherwise this input is never evaluated.
    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # The REAL upstream Omarchy 4 ("Quattro") tree, consumed verbatim (not a
    # flake — it's a plain dotfiles/scripts repo). Only used by macnix's
    # experimental `enableOmarchy4Session` toggle, which runs it isolated in
    # ~/.config-omarchy4 next to the normal Hyprland session. See
    # hosts/linux/macnix/omarchy4-session.nix.
    omarchy4 = {
      url = "github:omacom/omarchy";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, zen-browser, ... }:
    let
      callHost = path: args:
        let flake = import path;
        in flake.outputs (args // { self = {}; });

      sharedModules = import ./modules;

      hostArgs = { inherit nixpkgs home-manager sharedModules; };
      blackMacArgs = hostArgs // { "nixpkgs-unstable" = inputs.nixpkgs-unstable; };
      macnixArgs = hostArgs // { inherit zen-browser; "nixpkgs-unstable" = inputs.nixpkgs-unstable; "omarchy-nix" = inputs.omarchy-nix; "omarchy4" = inputs.omarchy4; };
      nasArgs = hostArgs // { "nixpkgs-unstable" = inputs.nixpkgs-unstable; };
      pi5Args = hostArgs // { "nixpkgs-unstable" = inputs.nixpkgs-unstable; };
    in {
      homeConfigurations = {
        # macOS hosts
        "runih@BlackMac"              = (callHost ./hosts/mac/BlackMac/flake.nix       blackMacArgs).homeConfigurations.runih;
        "runih@MaikensMac.local"      = (callHost ./hosts/mac/MaikensMac/flake.nix      hostArgs).homeConfigurations.MaikensMac;
        "runih@iMac.home.okkara.net"  = (callHost ./hosts/mac/iMac/flake.nix           hostArgs).homeConfigurations.iMac;

        # Linux hosts
        "runih@macnix"         = (callHost ./hosts/linux/macnix/flake.nix        macnixArgs).homeConfigurations.macnix;
        "runih@nixos-pi5"      = (callHost ./hosts/linux/nixos-pi5/flake.nix     pi5Args).homeConfigurations.nixos-pi5;
        "minecraft@nixos-pi5"  = (callHost ./hosts/linux/nixos-pi5/flake.nix     pi5Args).homeConfigurations.minecraft;
        "runih@nixos"          = (callHost ./hosts/linux/nixos/flake.nix         hostArgs).homeConfigurations.nixos;
        "runih@nixos2"         = (callHost ./hosts/linux/nixos2/flake.nix        hostArgs).homeConfigurations.nixos2;
        "runih@madakara-nixos" = (callHost ./hosts/linux/madakara-nixos/flake.nix hostArgs).homeConfigurations.madakara-nixos;
        "nas"                  = (callHost ./hosts/linux/nas/flake.nix           nasArgs).homeConfigurations.nas;
      };
    };
}
