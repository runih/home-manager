{
  description = "Home Manager configuration for runih@BlackMac";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }:
    let
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = "runih";
      homeDirectory = "/Users/${username}";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    in {
      homeConfigurations."${username}" = mkHome {
        system = "aarch64-darwin";
        inherit username homeDirectory;
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        modules = [
          { home.packages = [ pkgs-unstable.claude-code ]; }
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
          ../../../podman.nix
          ../../../claude-code.nix
        ];
      };
    };
}
