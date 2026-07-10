{
  description = "Home Manager configuration for nas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    {
      homeConfigurations = {
        "nas" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            ../../../nas.nix
            ../../../tmux.nix
            ../../../vim.nix
            ../../../neovim.nix
            ../../../zsh.nix
          ];
          extraSpecialArgs = {
            homeDirectory = "/volume1/homes/runihadmin";
            username = "runihadmin";
          };
        };
      };
    };
}
