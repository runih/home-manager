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

        username = builtins.getEnv "USER";  # Get the current user's username.


        # Define shared modules for macOS systems.
        # These modules include configurations specific to macOS, such as
        # macOS-specific tools, fonts, and terminal settings.
        sharedModulesMac = [
          ./basic-mac.nix           # Basic macOS-specific configurations.
          ./nerd-fonts.nix          # Configuration for Nerd Fonts.
          ./zsh.nix                 # Zsh shell configuration.
          ./zoxide.nix              # Zoxide configuration for macOS.
          ./my-tmux.nix             # Custom tmux configuration.
          ./vim.nix                 # Vim editor configuration.
          ./wezterm.nix             # WezTerm terminal emulator configuration.
          ./neovide.nix             # Neovide GUI for Neovim.
          ./pass.nix                # Password manager configuration.
          ./postgresql-client.nix   # PostgreSQL client configuration.
        ];

        # Define shared modules for Linux systems.
        # These modules include configurations specific to Linux, such as
        # Linux-compatible tools and terminal settings.
        sharedModulesLinux = [
          ./simple-tmux.nix     # Tmux configuration for Linux.
          ./vim.nix             # Vim editor configuration.
          ./zsh.nix             # Zsh shell configuration.
          ./zoxide.nix          # Zoxide configuration for Linux.
          ./yazi.nix            # Yazi configuration for Linux.
          ./pass.nix            # Password manager configuration.
        ];

      in {
        # Configuration for the user "runih" on the system "BlackMac" (macOS).
        "runih@BlackMac" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
          modules = sharedModulesMac ++ [ ./java.nix ./testssl.nix ];
          extraSpecialArgs = {
            homeDirectory = "/Users/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        "maiken@MaikensMacbook.local" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
          modules = sharedModulesMac ++ [ ./java.nix ./neovim.nix ];
          extraSpecialArgs = {
            homeDirectory = "/Users/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        # Configuration for the user "runih" on the system "BlackMac" (macOS).
        "runih@iMac.home.okkara.net" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
          modules = sharedModulesMac ++ [ ./imac.nix ./java.nix ];
          extraSpecialArgs = {
            homeDirectory = "/Users/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        # Configuration for the user "runih" on the system "nixos-pi5" (Linux).
        "runih@macnix" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          # List of Nix modules to include in this configuration.
          modules = [
            ./macnix.nix
            ./wezterm.nix
            ./foot.nix
            ./nerd-fonts.nix
            ./neovide.nix
            ./postgresql-client.nix
            ./hyprland.nix
            ./ghostty.nix
            ./testssl.nix
            ./java.nix
            ({ config, ...}: {
              nixpkgs.config.allowUnfree = true;  # Allow unfree packages in Nixpkgs.
            })
          ] ++ sharedModulesLinux;
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        # Configuration for the user "runih" on the system "nixos-pi5" (Linux).
        "runih@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          # List of Nix modules to include in this configuration.
          modules = [
            ./basic-linux.nix
            ./neovim.nix
          ] ++ sharedModulesLinux;
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        # Configuration for the "minecraft" user on the system "nixos-pi5" (Linux).
        "minecraft@nixos-pi5" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          modules = [
            ./simple-tmux.nix
            ./neovim.nix
            ./minecraft.nix
          ] ++ sharedModulesLinux;
          extraSpecialArgs = {
            homeDirectory = "/home/minecraft";  # Pass the home directory to the configuration.
            username = "minecraft";            # Pass the username to the configuration.
          };
        };

        # Configuration for the user "runih" on the system "nixos" (Linux).
        "runih@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux;
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        # Configuration for the user "runih" on the system "nixos2" (Linux).
        "runih@nixos2" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux";
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux;
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };

        # Configuration for the user "runih" on the system "madakara-nixos" (Linux).
        "runih@madakara-nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./basic-linux.nix ] ++ sharedModulesLinux ++ [ ../esh-minecraft.nix ];
          extraSpecialArgs = {
            homeDirectory = "/home/${username}";  # Pass the home directory to the configuration.
            username = username;            # Pass the username to the configuration.
          };
        };
      };
    };
}
