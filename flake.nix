{
  description = "Home Manager configuration of runih";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    execpermfix.url = "github:lpenz/execpermfix";
  };

  outputs = { nixpkgs, execpermfix, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        "runih" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./home.nix ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
        "macos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # modules = [
          #   {
          #     home = {
          #       username = "runih";
          #       homeDirectory = "/Users/runih";
          #       sessionPath = [
          #         "/Users/runih/.nix-profile/bin"
          #       ];

          #       stateVersion = "24.11"; # Please read the comment before changing.

          #       packages = with pkgs; [ 
          #         execpermfix.packages.${system}.default
          #       ];

          #       sessionVariables = {
          #         EDITOR = "nvim";
          #       };

          #     };
          #   }
          # ];
        };
      };
    };
}
