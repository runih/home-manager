{
  description = "Home Manager configuration for maiken@MaikensMacbook.local";

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
      homeConfigurations."MaikensMacbook" = mkHome {
        system = "aarch64-darwin";
        inherit username;
        homeDirectory = "/Users/${username}";
        modules = [
          ({ pkgs, ... }: { home.packages = [ pkgs.claude-code ]; })
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
          ../../../neovim.nix
          ../../../claude-code.nix
        ];
      };
    };
}
