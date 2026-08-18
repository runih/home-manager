{
  description = "Home Manager configuration for runih@MaikensMac.local";

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
      homeConfigurations."MaikensMac" = mkHome {
        system = "aarch64-darwin";
        inherit username;
        homeDirectory = "/Users/${username}";
        modules = [
          m.basic-mac
          m.nerd-fonts
          m.zsh
          m.zoxide
          m.simple-tmux
          m.neovim
          m.wezterm
          m.ollama
          # Bind to this machine's home-LAN IP specifically, not 0.0.0.0 —
          # off that network (no interface holds this address) the bind
          # fails at startup and Ollama simply isn't reachable anywhere,
          # instead of listening on whatever untrusted network it's on.
          { ollama.host = "192.168.7.12"; }
          # This machine isn't kept logged in (not personally owned), so the
          # gui/<uid> LaunchAgent from m.ollama can never bootstrap — macOS
          # only runs that domain during an active graphical session. Ollama
          # instead runs as a hand-installed system LaunchDaemon (see
          # ~/Projects/local-ai/CLAUDE.md), which starts at boot with no
          # login required. Disable the LaunchAgent here so the two don't
          # fight over port 11434; home.packages still installs the binary.
          ({ lib, ... }: { launchd.agents.ollama.enable = lib.mkForce false; })
        ];
      };
    };
}
