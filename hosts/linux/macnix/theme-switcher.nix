{ lib, homeDirectory, ... }:
let
  themes = import ./themes.nix;
  themeLib = import ./theme-lib.nix;
  themeNames = builtins.attrNames themes.themes;

  # One `name) B1=...; B2=...; INA=...; WALL=...;;` case-arm per theme, so the
  # hyprland border colors and wallpaper dir the switcher script uses come
  # from the same palette data as the waybar/wofi stylesheets (themes.nix).
  borderCases = lib.concatMapStringsSep "\n" (name:
    let p = themes.themes.${name}; in
    ''      ${name}) B1=${p.borderActive1}; B2=${p.teal}; INA=${p.border}; WALL=${p.wallpaperDir} ;;''
  ) themeNames;

  themeSwitchScript = ''
    #!/usr/bin/env bash
    set -euo pipefail

    STATE_DIR="$HOME/.local/state/theme-switcher"
    STATE_FILE="$STATE_DIR/current"
    WAYBAR_THEMES="$HOME/.config/waybar/themes"
    WOFI_THEMES="$HOME/.config/wofi/themes"
    WALLPAPER_ROOT="$HOME/Pictures/wallpapers"

    mkdir -p "$STATE_DIR"

    THEME="''${1:-}"

    if [ "$THEME" = "--restore" ]; then
      THEME=$(cat "$STATE_FILE" 2>/dev/null || true)
      [ -z "$THEME" ] && exit 0
    fi

    if [ -z "$THEME" ]; then
      THEME=$(printf '%s\n' ${lib.concatMapStringsSep " " (n: "\"${n}\"") themeNames} | wofi --show dmenu --prompt "Theme")
      [ -z "$THEME" ] && exit 0
    fi

    if [ ! -f "$WAYBAR_THEMES/$THEME.css" ]; then
      hyprctl notify -1 3000 'rgb(f7768e)' "Unknown theme: $THEME"
      exit 1
    fi

    cp --remove-destination "$WAYBAR_THEMES/$THEME.css" "$HOME/.config/waybar/style.css"
    systemctl --user restart waybar.service 2>/dev/null || true

    cp --remove-destination "$WOFI_THEMES/$THEME.css" "$HOME/.config/wofi/style.css"

    case "$THEME" in
    ${borderCases}
      *) B1=""; B2=""; INA=""; WALL="" ;;
    esac

    if [ -n "$B1" ]; then
      hyprctl keyword general:col.active_border "rgba(''${B1}ff) rgba(''${B2}ff) 45deg"
      hyprctl keyword general:col.inactive_border "rgb($INA)"
    fi

    WALL_PICK=""
    if [ -n "$WALL" ] && [ -d "$WALLPAPER_ROOT/$WALL" ]; then
      WALL_PICK=$(find "$WALLPAPER_ROOT/$WALL" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n1)
    fi
    if [ -n "$WALL_PICK" ]; then
      "$HOME/bin/change_wallpaper" "$WALL_PICK"
    else
      "$HOME/bin/change_wallpaper" --random
    fi

    echo "$THEME" > "$STATE_FILE"
    hyprctl notify -1 2000 "rgb(''${B1:-7aa2f7})" "Theme: $THEME"
  '';
in {
  home.file = (builtins.listToAttrs (map (name: {
    name = ".config/waybar/themes/${name}.css";
    value.text = themeLib.mkWaybarStyle themes.themes.${name};
  }) themeNames)) // (builtins.listToAttrs (map (name: {
    name = ".config/wofi/themes/${name}.css";
    value.text = themeLib.mkWofiStyle themes.themes.${name};
  }) themeNames)) // {
    "bin/theme-switch" = {
      text = themeSwitchScript;
      executable = true;
    };
  };

  systemd.user.services.theme-switcher-restore = {
    Unit = {
      Description = "Reapply the last-selected Hyprland theme";
      After = [ "graphical-session.target" "waybar.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${homeDirectory}/bin/theme-switch --restore";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
