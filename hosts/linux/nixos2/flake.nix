{
  description = "Home Manager configuration for runih@nixos2";

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
      username = builtins.getEnv "USER";
    in {
      homeConfigurations."nixos2" = mkHome {
        system = "aarch64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        modules = [
          ../../../basic-linux.nix
          ../../../simple-tmux.nix
          ../../../vim.nix
          ../../../zsh.nix
          ../../../zoxide.nix
          ../../../yazi.nix
          ../../../pass.nix
        ];
      };
    };
}
