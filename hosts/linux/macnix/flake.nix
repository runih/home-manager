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
    # Only consumed when `enableOmarchy` (below) is true. Ignored when this
    # host is built through the root flake, which injects its own copy.
    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Upstream Omarchy 4 tree — only consumed when `enableOmarchy4Session`
    # below is true. Ignored when built through the root flake (which
    # injects its own copy via macnixArgs).
    omarchy4 = {
      url = "github:omacom/omarchy";
      flake = false;
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, zen-browser, sharedModules, omarchy-nix ? null, omarchy4 ? null, ... }:
    let
      m = sharedModules;
      lib = nixpkgs.lib;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";  # Get the current user's username.

      # Desktop-stack selection (omarchy-nix vs hand-rolled Hyprland) and
      # the two additive "extra GDM session" toggles — see
      # ./desktop/toggle.nix.
      desktop = import ./desktop/toggle.nix {
        inherit lib m home-manager nixpkgs omarchy-nix omarchy4;
      };
      inherit (desktop)
        enableOmarchy
        enableOmarchySession
        omarchySessionModule
        enableOmarchy4Session
        omarchy4SessionModule
        withoutOmarchy
        desktopModules;
    in {
      homeConfigurations."macnix" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          (import ./home/packages.nix { inherit zen-browser lib enableOmarchy; })
          ./home
        ] ++ desktopModules ++ [
          m.wezterm
          m.foot
          m.nerd-fonts
          m.neovide
          m.postgresql-client
        ] ++ withoutOmarchy m.ghostty ++ [
          m.testssl
          m.java
          m.simple-tmux
          m.podman
          m.fastfetch
          { host.hasBattery = true; }
          m.vim
          m.doom-emacs
        ] ++ withoutOmarchy m.zsh ++ withoutOmarchy m.zoxide
          ++ lib.optional (enableOmarchySession && !enableOmarchy) omarchySessionModule
        ++ lib.optional (enableOmarchy4Session && !enableOmarchy) omarchy4SessionModule ++ [
          m.pass
          m.ssh_config
          m.claude-code
          m.copilot-cli
          m.opencode
          m.allowUnfree
          (import ./home/agent-tools.nix)
        ];
      };
    };
}
