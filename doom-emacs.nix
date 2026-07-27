{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    emacs-pgtk
    nixd
  ];

  home.activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.emacs-pgtk}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"

    if [ ! -d "$HOME/.config/emacs" ]; then
      $DRY_RUN_CMD git clone --depth 1 \
        https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
    fi
    if [ ! -d "$HOME/.config/doom" ]; then
      $DRY_RUN_CMD "$HOME/.config/emacs/bin/doom" install --no-env --force
    fi
  '';
}
