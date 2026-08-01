{
  description = "Home Manager configuration for maiken@MaikensMacbook.local";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sharedModules, ... }:
    let
      m = sharedModules;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";
    in {
      homeConfigurations."MaikensMacbook" = mkHome {
        system = "aarch64-darwin";
        inherit username;
        homeDirectory = "/Users/${username}";
        modules = [
          ({ pkgs, ... }: { home.packages = [ pkgs.claude-code ]; })
          m.basic-mac
          m.nerd-fonts
          m.zsh
          m.zoxide
          m.my-tmux
          m.vim
          m.wezterm
          m.neovide
          m.pass
          m.postgresql-client
          m.java
          m.neovim
          m.claude-code
          m.copilot-cli
        ];
      };
    };
}
