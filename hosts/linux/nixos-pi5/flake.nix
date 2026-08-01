{
  description = "Home Manager configuration for runih@nixos-pi5";

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
      username = builtins.getEnv "USER";  # Get the current user's username.
    in {
      homeConfigurations."nixos-pi5" = mkHome {
        system = "aarch64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          ({ pkgsUnstable, ... }: { home.packages = [ pkgsUnstable.claude-code ]; })
          ./home.nix

          m.neovide
          m.postgresql-client
          m.testssl
          m.java
          m.simple-tmux
          m.vim
          m.zsh
          m.zoxide
          m.pass
          m.claude-code
          m.copilot-cli
          m.allowUnfree
        ];
      };

      homeConfigurations."minecraft" = mkHome {
        system = "aarch64-linux";
        username = "minecraft";
        homeDirectory = "/home/minecraft";
        modules = [
          m.simple-tmux
          m.neovim
          m.minecraft
          m.vim
          m.zsh
          m.zoxide
          m.yazi
          m.pass
          m.allowUnfree
        ];
      };
    };
}
