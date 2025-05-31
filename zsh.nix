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
      cd = "z";
      cdi = "zi";
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
