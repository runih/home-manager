{
  description = "Home Manager configuration for runih@macnix";

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
        "macnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            ./home.nix
            ./hyprland.nix

            ../../../niri.nix
            ../../../wezterm.nix
            ../../../foot.nix
            ../../../nerd-fonts.nix
            ../../../neovide.nix
            ../../../postgresql-client.nix
            ../../../ghostty.nix
            ../../../testssl.nix
            ../../../java.nix
            ../../../simple-tmux.nix
            ../../../vim.nix
            ../../../zsh.nix
            ../../../zoxide.nix
            #../../../yazi.nix
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
