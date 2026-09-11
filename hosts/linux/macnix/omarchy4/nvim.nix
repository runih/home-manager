# Omarchy 4's Neovim is the `omarchy-nvim` / `omarchy-lazyvim` Arch package
# (LazyVim starter + a thin overlay + a pre-built plugin cache) — no Nix
# equivalent, so build the config half from its parts here and let
# lazy.nvim bootstrap the plugins on first launch. Isolated from the user's
# real ~/.config/nvim via NVIM_APPNAME=omarchy-nvim in ./launcher.nix.
#
# The runCommand body is kept byte-for-byte as it was in the old
# omarchy4-session.nix so the `omarchy4-nvim-config` store path does not move.

{ pkgs }:

let
  lazyvimStarter = pkgs.fetchFromGitHub {
    owner = "LazyVim";
    repo = "starter";
    rev = "803bc181d7c0d6d5eeba9274d9be49b287294d99";
    hash = "sha256-QrpnlDD4r1X4C8PqBhQ+S3ar5C+qDrU1Jm/lPqyMIFM=";
  };
  omarchyLazyvim = pkgs.fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-lazyvim";
    rev = "17dcc3706475f2cd719d831394323f29314bf0ba";
    hash = "sha256-lEBmjGj7ela26VqC4W4dYv+TSU+xAqGk0izbzwSi8mQ=";
  };
in
pkgs.runCommand "omarchy4-nvim-config" { } ''
    cp -r ${lazyvimStarter} $out
    chmod -R u+w $out
    rm -rf $out/.git

    # omarchy-lazyvim's overlay on top of the LazyVim starter (see its
    # PKGBUILD): the neo-tree extra, the transparency after/ plugin, the
    # animated-scrolling-off spec, and relativenumber off.
    install -Dm644 ${omarchyLazyvim}/lazyvim.json $out/lazyvim.json
    cp -r ${omarchyLazyvim}/plugin $out/
    install -Dm644 \
      ${omarchyLazyvim}/lua/plugins/snacks-animated-scrolling-off.lua \
      $out/lua/plugins/snacks-animated-scrolling-off.lua
    printf '\nvim.opt.relativenumber = false\n' >> $out/lua/config/options.lua

    # NOT copying omarchy-lazyvim's static lua/plugins/theme.lua — that slot
    # is a live symlink to Omarchy's current-theme state (home.file below),
    # so the colorscheme follows `omarchy theme set`.
  ''
