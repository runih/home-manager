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
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      username = builtins.getEnv "USER";
    in {
      homeConfigurations."nas" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/var/services/homes/${username}";
        modules = [
          { home.packages = [ pkgs-unstable.claude-code ]; }
          ./home.nix
          ../../../simple-tmux.nix
          ../../../vim.nix
          ../../../neovim.nix
          ../../../zsh.nix
          ../../../zoxide.nix
          ({ config, ... }: {
            nixpkgs.config.allowUnfree = true;
          })
        ];
      };
    };
}
