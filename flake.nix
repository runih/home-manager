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
      homeConfigurations = let

        # Define shared modules for macOS systems.
        # These modules include configurations specific to macOS, such as
        # macOS-specific tools, fonts, and terminal settings.
        sharedModulesMac = [
          ./basic-mac.nix       # Basic macOS-specific configurations.
          ./nerd-fonts.nix      # Configuration for Nerd Fonts.
          #./ghostty.nix         # Ghostty terminal settings. (it is still broken)
          ./zsh.nix             # Zsh shell configuration.
          ./my-tmux.nix         # Custom tmux configuration.
          ./vim.nix             # Vim editor configuration.
          ./wezterm.nix         # WezTerm terminal emulator configuration.
          ./neovide.nix         # Neovide GUI for Neovim.
          ./pass.nix            # Password manager configuration.
        ];

        # Define shared modules for Linux systems.
        # These modules include configurations specific to Linux, such as
        # Linux-compatible tools and terminal settings.
        sharedModulesLinux = [
          ./tmux.nix            # Tmux configuration for Linux.
          ./vim.nix             # Vim editor configuration.
          ./neovim.nix          # Neovim editor configuration.
          ./zsh.nix             # Zsh shell configuration.
        ];

      in {
        # Configuration for the user "runih" on the system "BlackMac" (macOS).
        "runih@BlackMac" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
          modules = sharedModulesMac ++ [ ./java.nix ];
        };

        # Configuration for the user "runih" on the system "nixos-pi5" (Linux).
        "runih@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          # List of Nix modules to include in this configuration.
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux;
        };

        # Configuration for the "minecraft" user on the system "nixos-pi5" (Linux).
        "minecraft@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./minecraft.nix ] ++ sharedModulesLinux;
        };

        # Configuration for the user "runih" on the system "nixos" (Linux).
        "runih@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux;
        };

        # Configuration for the user "runih" on the system "nixos2" (Linux).
        "runih@nixos2" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux;
        };

        # Configuration for the user "runih" on the system "madakara-nixos" (Linux).
        "runih@madakara-nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux ++ [ ../esh-minecraft.nix ];
        };
      };
    };
}
