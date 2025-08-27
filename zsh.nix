{ homeDirectory, ... }:
{
  home.sessionPath = [ "${homeDirectory}/bin" ];
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    shellAliases = {
      hm = "home-manager switch --impure";
      apps = "home-manager generations | awk '$0 ~ /(current)/ {print \"open \"$7\"/home-path/Applications\"}' | sh";
    };
    initContent = ''
    unset __HM_SESS_VARS_SOURCED
    if [ -e ${homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . ${homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi
    bindkey -v
    bindkey -M viins '^E' end-of-line
    '';
  };
}
