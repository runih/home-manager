{
  description = "Home Manager configuration for runih@nixos-pi5";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      username = builtins.getEnv "USER";  # Get the current user's username.
    in {
      homeConfigurations = {
        "nixos-pi5" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [
            ./home.nix

            ../../../neovide.nix
            ../../../postgresql-client.nix
            ../../../testssl.nix
            ../../../java.nix
            ../../../simple-tmux.nix
            ../../../vim.nix
            ../../../zsh.nix
            ../../../zoxide.nix
            ../../../pass.nix
            ({ config, ... }: {
              nixpkgs.config.allowUnfree = true;
            })
          ];
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";
            username = username;
          };
        };

        "minecraft" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [
            ../../../simple-tmux.nix
            ../../../neovim.nix
            ../../../minecraft.nix
            ../../../vim.nix
            ../../../zsh.nix
            ../../../zoxide.nix
            ../../../yazi.nix
            ../../../pass.nix
            ({ config, ... }: {
              nixpkgs.config.allowUnfree = true;
            })
          ];
          extraSpecialArgs = {
            homeDirectory = "/home/minecraft";
            username = "minecraft";
          };
        };
      };
    };
}
