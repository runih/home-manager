{ ... }:
{
  programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      # -u skips compinit's ownership check on completion dirs. Nix store paths are
      # content-addressed and owned by whichever user first built/fetched them, which
      # trips the check as a false positive on any machine where that isn't $USER.
      completionInit = "autoload -U compinit && compinit -u";
      defaultKeymap = "viins";
      # bindkey -v (from defaultKeymap) switches the active keymap to viins, where ^E
      # is self-insert instead of end-of-line — so it never triggers zsh-autosuggestions'
      # accept-on-end-of-line wrapping like it does in the default emacs keymap.
      initContent = ''
        bindkey -M viins '^E' end-of-line
      '';
      shellAliases = {
        cd = "z";
        cdi = "zi";
        hm = "home-manager switch --impure --flake ~/.config/home-manager#$USER@$(hostname)";
      };
    };
}
