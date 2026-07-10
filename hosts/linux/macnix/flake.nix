{
  description = "Home Manager configuration for runih@macnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, zen-browser, ... }:
    let
      username = builtins.getEnv "USER";  # Get the current user's username.
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      homeConfigurations = {
        "macnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            { home.packages = [ zen-browser.packages."x86_64-linux".default pkgs-unstable.gh pkgs-unstable.claude-code ]; }
            ./home.nix
            ./hyprland.nix
            ./waybar.nix

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
