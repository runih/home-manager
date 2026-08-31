{
  description = "Home Manager configuration for runih@macnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, zen-browser, sharedModules, ... }:
    let
      m = sharedModules;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";  # Get the current user's username.
    in {
      homeConfigurations."macnix" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          ({ pkgsUnstable, ... }: { home.packages = [ zen-browser.packages."x86_64-linux".default pkgsUnstable.gh pkgsUnstable.claude-code pkgsUnstable.ollama ]; })
          ./home.nix
          ./hyprland.nix
          ./waybar.nix
          ./theme-switcher.nix

          m.niri
          m.wezterm
          m.foot
          m.nerd-fonts
          m.neovide
          m.postgresql-client
          m.ghostty
          m.testssl
          m.java
          m.simple-tmux
          m.podman
          { host.hasBattery = true; }
          m.vim
          m.doom-emacs
          m.zsh
          m.zoxide
          m.pass
          m.ssh_config
          m.claude-code
          m.copilot-cli
          m.opencode
          m.allowUnfree
          {
            copilotCli.allowedUrls = [
              "http://localhost:8080"
              "http://localhost:7000"
              "http://172.16.4.10:8080"
              "http://192.168.7.37:8080"
              "http://192.168.7.37:7000"
              "https://gitlab.com"
            ];
          }
          {
            claudeCode.hooks = {
              Stop = [
                {
                  hooks = [
                    { type = "command"; command = ''hyprctl notify -1 2000 'rgb(7aa2f7)' 'Claude is done' 2>/dev/null || true''; }
                  ];
                }
              ];
              Notification = [
                {
                  hooks = [
                    { type = "command"; command = ''hyprctl notify -1 2000 'rgb(7aa2f7)' 'Claude is waiting for input' 2>/dev/null || true''; }
                  ];
                }
              ];
              PostToolUse = [
                {
                  matcher = "Bash";
                  hooks = [
                    { type = "command"; command = ''cmd=$(jq -r '.tool_input.command'); [[ "$cmd" == "hm"* ]] && hyprctl notify -1 2000 'rgb(7aa2f7)' 'Configuration reloaded' 2>/dev/null || true''; }
                  ];
                }
              ];
            };
          }
        ];
      };
    };
}
