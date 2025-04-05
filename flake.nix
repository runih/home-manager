{
  # Description of the flake, providing a brief summary of its purpose.
  description = "Home Manager configuration of runih";

  inputs = {
    # Specify the source of Nixpkgs, using the nixos-unstable branch.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Specify the source of Home Manager, following the nixpkgs input for compatibility.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    {
      homeConfigurations = {
        # Configuration for the user "runih" on the system "BlackMac" (macOS).
        "runih@BlackMac" = inputs.home-manager.lib.homeManagerConfiguration {
          # Use the package set for macOS (aarch64-darwin).
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";

          # List of Nix modules to include in this configuration.
          modules = [
            ./basic-mac.nix       # Basic macOS-specific settings.
            ./nerd-fonts.nix      # Configuration for Nerd Fonts.
            ./ghostty.nix         # Ghostty terminal settings.
            ./zsh.nix             # Zsh shell configuration.
            ./my-tmux.nix         # Custom tmux configuration.
            ./vim.nix             # Vim editor configuration.
            ./wezterm.nix         # WezTerm terminal emulator settings.
            ./neovide.nix         # Neovide GUI for Neovim.
            ./pass.nix            # Password manager configuration.
          ];
        };

        # Configuration for the user "runih" on the system "nixos-pi5" (Linux).
        "runih@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          # Use the package set for Linux (aarch64-linux).
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          # List of Nix modules to include in this configuration.
          modules = [
            ./basic-linux.nix     # Basic Linux-specific settings.
            ./tmux.nix            # Tmux configuration.
            ./vim.nix             # Vim editor configuration.
            ./neovim.nix          # Neovim editor configuration.
            ./zsh.nix             # Zsh shell configuration.
          ];
        };

        # Configuration for the "minecraft" user on the system "nixos-pi5" (Linux).
        "minecraft@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          # Use the package set for Linux (aarch64-linux).
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          # List of Nix modules to include in this configuration.
        modules = [
          ./minecraft.nix       # Minecraft-specific settings.
            ./tmux.nix            # Tmux configuration.
            ./vim.nix             # Vim editor configuration.
            ./zsh.nix             # Zsh shell configuration.
          ];
        };

        # Configuration for the user "runih" on the system "nixos" (Linux).
        "runih@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          # Use the package set for Linux (aarch64-linux).
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          # List of Nix modules to include in this configuration.
          modules = [
            ./basic-linux.nix     # Basic Linux-specific settings.
            ./tmux.nix            # Tmux configuration.
            ./vim.nix             # Vim editor configuration.
            ./neovim.nix          # Neovim editor configuration.
            ./zsh.nix             # Zsh shell configuration.
          ];
        };

        # Configuration for the user "runih" on the system "nixos2" (Linux).
        "runih@nixos2" = inputs.home-manager.lib.homeManagerConfiguration {
          # Use the package set for Linux (aarch64-linux).
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";

          # List of Nix modules to include in this configuration.
          modules = [
            ./basic-linux.nix     # Basic Linux-specific settings.
            ./tmux.nix            # Tmux configuration.
            ./vim.nix             # Vim editor configuration.
            ./neovim.nix          # Neovim editor configuration.
            ./zsh.nix             # Zsh shell configuration.
          ];
        };

        # Configuration for the user "runih" on the system "madakara-nixos" (Linux).
        "runih@madakara-nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          # Use the package set for Linux (x86_64-linux).
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";

          # List of Nix modules to include in this configuration.
          modules = [
            ./basic-linux.nix     # Basic Linux-specific settings.
            ./esh-minecraft.nix   # Minecraft-specific settings for ESH.
            ./tmux.nix            # Tmux configuration.
            ./vim.nix             # Vim editor configuration.
            ./neovim.nix          # Neovim editor configuration.
            ./zsh.nix             # Zsh shell configuration.
          ];
        };
      };
    };
}
