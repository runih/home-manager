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

  outputs = inputs @ { nixpkgs, home-manager, zen-browser, ... }:
    let
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";  # Get the current user's username.
    in {
      homeConfigurations."macnix" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          ({ pkgsUnstable, ... }: { home.packages = [ zen-browser.packages."x86_64-linux".default pkgsUnstable.gh pkgsUnstable.claude-code ]; })
          ./home.nix
          ./hyprland.nix
          ./waybar.nix

          ../../../niri.nix
          ../../../wezterm.nix
          ../../../foot.nix
          ../../../nerd-fonts.nix
          ../../../neovide.nix
          ../../../postgresql-client.nix
          ../../../ghostty.nix
          ../../../testssl.nix
          ../../../java.nix
          ../../../simple-tmux.nix
          { host.hasBattery = true; }
          ../../../vim.nix
          ../../../zsh.nix
          ../../../zoxide.nix
          ../../../pass.nix
          ../../../claude-code.nix
          ../../../lib/allowUnfree.nix
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
