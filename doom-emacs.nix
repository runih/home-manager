{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    emacs-pgtk
    nixd
    lua-language-server
  ];

  xdg.configFile = {
    "doom/init.el".source = ./doom.d/init.el;
    "doom/config.el".source = ./doom.d/config.el;
    "doom/packages.el".source = ./doom.d/packages.el;
  };

  home.activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.emacs-pgtk}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"

    if [ ! -d "$HOME/.config/emacs" ]; then
      $DRY_RUN_CMD git clone --depth 1 \
        https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
    fi
    # $DOOMDIR (~/.config/doom) is now always populated by home-manager,
    # so use doom's package data dir as the "already installed" marker
    # instead -- otherwise `doom install` would never run.
    if [ ! -d "$HOME/.config/emacs/.local" ]; then
      $DRY_RUN_CMD "$HOME/.config/emacs/bin/doom" install --no-env --force
    fi
  '';
}
