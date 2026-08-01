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

  outputs = inputs @ { nixpkgs, home-manager, sharedModules, ... }:
    let
      m = sharedModules;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";
    in {
      homeConfigurations."nas" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/var/services/homes/${username}";
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          ({ pkgsUnstable, ... }: { home.packages = [ pkgsUnstable.claude-code ]; })
          ./home.nix
          m.simple-tmux
          m.vim
          m.neovim
          m.zsh
          m.zoxide
          m.claude-code
          m.copilot-cli
          m.allowUnfree
        ];
      };
    };
}
