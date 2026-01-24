{
  description = "Home Manager configuration for runih@macnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      username = "runih";
    in {
      homeConfigurations = {
        "runih@macnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            ./home.nix
            ../../../wezterm.nix
            ../../../foot.nix
            ../../../nerd-fonts.nix
            ../../../neovide.nix
            ../../../postgresql-client.nix
            ../../../hyprland.nix
            ../../../ghostty.nix
            ../../../testssl.nix
            ../../../java.nix
            ../../../simple-tmux.nix
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
            homeDirectory = "/home/${username}";
            username = username;
          };
        };
      };
    };
}
