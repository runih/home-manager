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
  };

  outputs = inputs @ { nixpkgs, home-manager, zen-browser, sharedModules, omarchy-nix ? null, ... }:
    let
      m = sharedModules;
      lib = nixpkgs.lib;
      mkHome = import ../../../lib/mkHome.nix { inherit nixpkgs home-manager; };
      username = builtins.getEnv "USER";  # Get the current user's username.

      # ---------------------------------------------------------------------
      # Omarchy toggle
      #
      # false (default): the hand-rolled desktop stack (hyprland.nix +
      #   waybar.nix + theme-switcher.nix + desktop-local.nix + m.niri) and
      #   the shared ghostty/zsh/zoxide modules are used, exactly as before.
      # true: all of that is dropped and replaced by omarchy-nix's
      #   opinionated home-manager module (Hyprland, waybar, wofi, hyprlock,
      #   ghostty, zsh, zoxide, starship, mako, btop, theming, ...).
      #
      # Still owned by this repo's config even when omarchy is on, so watch
      # for clashes: home.nix's oh-my-posh (vs omarchy's starship), vim /
      # doom-emacs (vs omarchy's bare neovim), wezterm, foot.
      #
      # Flipping this on ALSO needs the system side: flip `enableOmarchy` in
      # ./nixos/flake.nix and reconcile the conflicts listed in
      # ./nixos/omarchy.nix, then `nixos-switch`. omarchy-nix targets
      # nixos-unstable; it is pinned to nixos-26.05 here via `follows`, so
      # expect to iterate if upstream uses something newer than 26.05 ships.
      # ---------------------------------------------------------------------
      enableOmarchy = true;

      # Hand-rolled desktop stack — used only when the toggle is off.
      customDesktopModules = [
        ./hyprland.nix
        ./waybar.nix
        ./theme-switcher.nix
        ./desktop-local.nix
        m.niri
      ];

      # Shared shell/terminal modules that omarchy-nix's home-manager module
      # also configures. Kept in their original list positions below (via
      # `withoutOmarchy`) so the toggle-off build is unchanged; omarchy owns
      # these when the toggle is on.
      withoutOmarchy = mod: lib.optional (!enableOmarchy) mod;

      omarchyModules = [
        omarchy-nix.homeManagerModules.default
        {
          # `m.zsh` normally provides the `hm` / rebuild aliases; keep them
          # when omarchy's own zsh config takes over.
          programs.zsh.shellAliases.hm =
            "home-manager switch --impure --flake ~/.config/home-manager#$USER@$(hostname)";

          # omarchy enables a bare, unconfigured `programs.neovim` ("TODO:
          # Add an actual nvim config" upstream). macnix already installs
          # its own `pkgs.neovim` in home.nix and sets EDITOR=nvim — the two
          # collide on `bin/nvim` in the profile. Keep macnix's.
          programs.neovim.enable = lib.mkForce false;
        }
        {
          # omarchy-nix's home-manager module is written to run as part of a
          # NixOS system: it pulls its `omarchy.*` settings from
          # `osConfig.omarchy`, and hyprland/envs.nix reads
          # `osConfig.services.xserver.videoDrivers`. In this repo's
          # standalone home-manager setup `osConfig` is `null`, so we shim a
          # minimal one here. macnix is Intel-graphics only, so the NVIDIA
          # env branch resolves to false.
          _module.args.osConfig = {
            services.xserver.videoDrivers = [ ];
            omarchy = {
              full_name = "Rúni H.Hansen";
              email_address = "runi.hansen@okkara.net";
              theme = "tokyo-night";
              scale = 2;
            };
          };
        }
      ];

      desktopModules =
        if enableOmarchy then omarchyModules else customDesktopModules;
    in {
      homeConfigurations."macnix" = mkHome {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        nixpkgsUnstable = inputs.nixpkgs-unstable;
        modules = [
          # `gh` from unstable is dropped when omarchy is on — its git.nix
          # enables `programs.gh` (stable), and two gh's collide in the profile.
          ({ pkgsUnstable, ... }: {
            home.packages = [ zen-browser.packages."x86_64-linux".default pkgsUnstable.claude-code pkgsUnstable.ollama ]
              ++ lib.optional (!enableOmarchy) pkgsUnstable.gh;
          })
          ./home.nix
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
          { host.hasBattery = true; }
          m.vim
          m.doom-emacs
        ] ++ withoutOmarchy m.zsh ++ withoutOmarchy m.zoxide ++ [
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
