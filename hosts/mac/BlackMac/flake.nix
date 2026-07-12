{
  description = "Home Manager configuration for runih@BlackMac";

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
      username = "runih";
      homeDirectory = "/Users/${username}";
    in {
      homeConfigurations."${username}" = mkHome {
        system = "aarch64-darwin";
        inherit username homeDirectory;
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
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
          ../../../java.nix
          ../../../testssl.nix
        ];
      };
    };
}
