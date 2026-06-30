{
  description = "Home Manager configuration for runih@nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      username = builtins.getEnv "USER";
    in {
      homeConfigurations = {
        "nixos" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [
            ../../../basic-linux.nix
            ../../../simple-tmux.nix
            ../../../vim.nix
            ../../../zsh.nix
            ../../../zoxide.nix
            ../../../yazi.nix
            ../../../pass.nix
          ];
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";
            username = username;
          };
        };
      };
    };
}
