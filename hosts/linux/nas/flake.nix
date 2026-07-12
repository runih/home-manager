{
  description = "Home Manager configuration for nas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      homeConfigurations = {
        "nas" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            { home.packages = [ pkgs-unstable.claude-code ]; }
            ./home.nix
            ../../../simple-tmux.nix
            ../../../vim.nix
            ../../../neovim.nix
            ../../../zsh.nix
            ({ config, ... }: {
              nixpkgs.config.allowUnfree = true;
            })
          ];
          extraSpecialArgs = {
            homeDirectory = "/var/services/homes/runihadmin";
            username = "runihadmin";
          };
        };
      };
    };
}
