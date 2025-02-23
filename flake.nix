{
  description = "Home Manager configuration of runih";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    {
      homeConfigurations = {
        "runih@BlackMac" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";

          modules = [
            ./home.nix
          ];

        };
        "runih@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic.nix
            ./tmux.nix
            ./vim.nix
            ./neovim.nix
          ];

        };
        "minecraft@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic.nix
            ./tmux.nix
            ./vim.nix
          ];

        };
        "runih@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic.nix
            ./tmux.nix
            ./vim.nix
            ./neovim.nix
          ];

        };
        "runih@nixos2" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic.nix
            ./tmux.nix
            ./vim.nix
            ./neovim.nix
          ];

        };
      };
    };
}
