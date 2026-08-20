{
  description = "Home Manager configuration for runih@BlackMac";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, sharedModules, ... }:
    let
      m = sharedModules;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = "runih";
      homeDirectory = "/Users/${username}";
    in {
      homeConfigurations."${username}" = mkHome {
        system = "aarch64-darwin";
        inherit username homeDirectory;
        allowUnfree = true;
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          ({ pkgsUnstable, ... }: { home.packages = [ pkgsUnstable.claude-code pkgsUnstable.github-copilot-cli ]; })
          ({ pkgs, ... }: { home.packages = [ pkgs.vscode ]; })
          m.basic-mac
          m.nerd-fonts
          m.zsh
          m.zoxide
          m.my-tmux
          m.vim
          m.doom-emacs
          m.wezterm
          m.neovide
          m.pass
          m.postgresql-client
          m.java
          m.testssl
          m.claude-code
          m.copilot-cli
          m.opencode
          m.lima
          m.ollama
          # Bind to this machine's home-LAN IP specifically, not 0.0.0.0 —
          # off that network (no interface holds this address) the bind
          # fails at startup and Ollama simply isn't reachable anywhere,
          # instead of listening on whatever untrusted network it's on.
          { ollama.host = "192.168.7.11"; }
          # Same reasoning as MaikensMac: run via a system LaunchDaemon
          # instead of the gui/<uid> user agent, so it's not tied to an
          # active login session. See ~/Projects/local-ai/CLAUDE.md.
          ({ lib, ... }: { launchd.agents.ollama.enable = lib.mkForce false; })
        ];
      };
    };
}
