{ homeDirectory, ... }:

# Shell/CLI `programs.*` config, split out of home.nix to keep that file
# focused on core `home.*` settings.
{
  programs = {
    # Enable home-manager for managing user configurations
    home-manager.enable = true;

    # Configuration for the eza program (modern ls replacement)
    eza = {
      enable = true;                  # Enable eza
      enableZshIntegration = true;    # Enable Zsh integration
      git = true;                     # Enable Git support
      icons = "auto";                 # Automatically enable icons
    };

    # Configuration for the fzf program (fuzzy finder)
    fzf = {
      enable = true;                  # Enable fzf
      enableZshIntegration = true;    # Enable Zsh integration
    };

    # Configuration for the oh-my-posh program (prompt theme engine)
    oh-my-posh = {
      enable = true;                  # Enable oh-my-posh
      enableZshIntegration = true;    # Enable Zsh integration
      useTheme = "blue-owl";
    };

    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };

    # Configuration for the vim program (text editor)
    vim = {
      enable = true;                  # Enable vim
    };

    # System rebuild always via explicit --flake path, not a bare
    # `nixos-rebuild switch` — a shim flake.nix under /etc/nixos can't
    # just `import` this repo's flake.nix (nix's flake front end needs a
    # literal attrset at the top of flake.nix to statically read `inputs`
    # before evaluation, so an indirection like that fails with
    # "must be an attribute set"). Same pattern as the `hm` alias.
    zsh.shellAliases = {
      nixos-switch = "sudo nixos-rebuild switch --flake ${homeDirectory}/.config/home-manager/hosts/linux/macnix/nixos#macnix";
    };
  };
}
