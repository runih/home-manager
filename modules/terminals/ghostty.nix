{ pkgs, lib, ... }:
let
ghostty-shaders = pkgs.fetchFromGitHub {
  owner = "0xhckr";
  repo = "ghostty-shaders";
  rev = "aa6121ba2ddd5251ac75b92729c758fe41256e55";
  hash = "sha256-2AeIjV59d/a+JdEbcPT1dLfUVdegRYIyFLI55daZ0LI=";
};
in
{
  # Default "no override" stub — a theme switcher (see hosts/linux/macnix)
  # can overwrite this with `theme = ...` / `cursor-color = ...` lines; ghostty
  # re-reads config-file includes on its own file-watch reload (or manual
  # reload_config keybind, already bound below).
  xdg.configFile."ghostty/current-theme" = {
    text = lib.mkDefault "";
    force = true;
  };

  # fzf picker over all ~460 bundled Ghostty themes (`ghostty +list-themes`),
  # independent of the curated dark/light pair hosts/linux/macnix/theme-switcher.nix
  # drives for the whole-desktop theme. Writes into the same current-theme
  # include, so it composes with (and is overwritten by) that switcher.
  home.file.".local/bin/ghostty-theme" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      SELF="$HOME/.local/bin/ghostty-theme"
      CURRENT_THEME_FILE="$HOME/.config/ghostty/current-theme"

      # Ghostty's `reload_config` keybind is a GTK action also reachable over
      # D-Bus (confirmed via `gdbus call ... org.gtk.Actions.Activate
      # reload-config`), which is how this script forces an instant redraw
      # instead of waiting on ctrl+shift+r or Ghostty's config file-watcher
      # (which doesn't reliably pick up writes to an included config-file).
      reload_ghostty() {
        gdbus call --session --dest com.mitchellh.ghostty \
          --object-path /com/mitchellh/ghostty \
          --method org.gtk.Actions.Activate reload-config '[]' '{}' >/dev/null 2>&1 || true
      }

      apply_theme() {
        printf 'theme = %s\n' "$1" > "$CURRENT_THEME_FILE"
        reload_ghostty
      }

      # Internal mode: fzf's focus binding below re-execs this script to
      # live-preview the highlighted theme on every arrow key / search change.
      if [ "''${1:-}" = "--apply" ]; then
        apply_theme "$2"
        exit 0
      fi

      # `ghostty +list-themes` spins up the full GTK app just to print names and
      # fails silently (exit 1, no output) outside a fully connected desktop
      # session, so read the bundled themes directory directly instead (found
      # via $GHOSTTY_RESOURCES_DIR, falling back to the ghostty binary's own
      # store path). Deliberately NOT scanning ~/.config/ghostty/themes here:
      # on macnix that directory holds dark.conf/light.conf staging files from
      # theme-switcher.nix's unrelated coarse switcher, not named theme files.
      RESOURCES_DIR="''${GHOSTTY_RESOURCES_DIR:-}"
      if [ -z "$RESOURCES_DIR" ]; then
        bin=$(readlink -f "$(command -v ghostty)")
        RESOURCES_DIR="$(dirname "$(dirname "$bin")")/share/ghostty"
      fi

      # home-manager manages current-theme as a symlink into the (read-only)
      # nix store, so break that once up front into a real, writable file
      # before the live-preview loop starts rewriting it on every arrow key.
      ORIGINAL=$(cat "$CURRENT_THEME_FILE" 2>/dev/null || true)
      rm -f "$CURRENT_THEME_FILE"
      printf '%s' "$ORIGINAL" > "$CURRENT_THEME_FILE"

      # Live preview: apply and instantly reload the highlighted theme on
      # every focus change (arrow keys / search). Enter keeps it; Esc/ctrl-c
      # (empty $THEME) restores and reloads the original below.
      THEME=$(ls "$RESOURCES_DIR/themes" | sort -u | fzf \
        --prompt="Ghostty theme> " --height=40% --reverse \
        --bind "focus:execute-silent($SELF --apply {})")

      if [ -z "$THEME" ]; then
        printf '%s' "$ORIGINAL" > "$CURRENT_THEME_FILE"
        reload_ghostty
        echo "Cancelled, restored previous theme"
        exit 0
      fi

      apply_theme "$THEME"
      echo "Ghostty theme set to: $THEME"
    '';
  };

  home.packages = [ pkgs.fzf pkgs.glib ]; # glib provides `gdbus`, used to trigger Ghostty's reload-config action

  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
      # GTK4 (4.20+/GNOME 49) dropped its built-in dead-key/compose fallback when no
      # IME is running, breaking things like the Swedish dead-key tilde in Ghostty.
      # Kitty/foot aren't GTK apps so they're unaffected. GTK_IM_MODULE=simple
      # restores basic dead-key handling without requiring ibus/fcitx.
      package = pkgs.symlinkJoin {
        name = "ghostty";
        paths = [ pkgs.ghostty ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ghostty --set GTK_IM_MODULE simple
        '';
        passthru = { inherit (pkgs.ghostty) vim; };
      };
    };
  };
  xdg.configFile."ghostty/config".text = ''
    window-padding-color = background
    theme = Dark Pastel
    # custom-shader = "shaders/cursor_blaze.glsl"
    background-opacity = 0.75
    macos-titlebar-style = hidden
    gtk-titlebar = false
    cursor-color = #ffff00
    cursor-style-blink = true
    cursor-style = block
    adjust-cursor-height = 30%
    font-family = "Iosevka Nerd Font Propo"
    font-size = 14
    keybind = global:shift+cmd+space=toggle_quick_terminal
    keybind = global:shift+ctrl+r=reload_config
    config-file = current-theme
    '';
  xdg.configFile."ghostty/shaders" = {
    source = ghostty-shaders;
    recursive = true;
  };
}
