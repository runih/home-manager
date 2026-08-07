{
  description = "Home Manager configuration for runih@madakara-nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sharedModules,
      ...
    }:
    let
      m = sharedModules;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";
    in
    {
      homeConfigurations."madakara-nixos" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        modules = [
          m.basic-linux
          m.simple-tmux
          m.vim
          m.zsh
          m.zoxide
          m.pass
          m.neovim
        ];
      };
    };
}
