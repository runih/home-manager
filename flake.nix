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
            ./basic-mac.nix
            ./nerd-fonts.nix
            ./ghostty.nix
            ./zsh.nix
            ./my-tmux.nix
            ./vim.nix
            ./wezterm.nix
            ./neovide.nix
            ./pass.nix
          ];

        };
        "runih@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic-linux.nix
            ./tmux.nix
            ./vim.nix
            ./neovim.nix
            ./zsh.nix
          ];

        };
        "minecraft@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./minecraft.nix
            ./tmux.nix
            ./vim.nix
            ./zsh.nix
          ];

        };
        "runih@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic-linux.nix
            ./tmux.nix
            ./vim.nix
            ./neovim.nix
            ./zsh.nix
          ];

        };
        "runih@nixos2" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          modules = [
            ./basic-linux.nix
            ./tmux.nix
            ./vim.nix
            ./neovim.nix
          ];

        };
      };
    };
}
