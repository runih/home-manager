{
  description = "Home Manager configuration for runih@iMac.home.okkara.net";

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
        "iMac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          modules = [
            ../../../basic-mac.nix
            ../../../nerd-fonts.nix
            ../../../zsh.nix
            ../../../zoxide.nix
            ../../../my-tmux.nix
            ../../../vim.nix
            ../../../wezterm.nix
            ../../../neovide.nix
            ../../../pass.nix
            ../../../postgresql-client.nix
            ../../../imac.nix
            ../../../java.nix
          ];
          extraSpecialArgs = {
            homeDirectory = "/Users/${username}";
            username = username;
          };
        };
      };
    };
}
