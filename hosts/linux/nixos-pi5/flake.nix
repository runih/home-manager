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
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";  # Get the current user's username.
      allowUnfree = ({ config, ... }: {
        nixpkgs.config.allowUnfree = true;
      });
    in {
      homeConfigurations."nixos-pi5" = mkHome {
        system = "aarch64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
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
          allowUnfree
        ];
      };

      homeConfigurations."minecraft" = mkHome {
        system = "aarch64-linux";
        username = "minecraft";
        homeDirectory = "/home/minecraft";
        modules = [
          ../../../simple-tmux.nix
          ../../../neovim.nix
          ../../../minecraft.nix
          ../../../vim.nix
          ../../../zsh.nix
          ../../../zoxide.nix
          ../../../yazi.nix
          ../../../pass.nix
          allowUnfree
        ];
      };
    };
}
