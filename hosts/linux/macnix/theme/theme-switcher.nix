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

  # Terminals (wezterm/foot/ghostty) only ship a "dark" and "light" look —
  # this maps each accent theme onto one of those two via themes.nix's mode
  # field, so picking any dark theme keeps the terminals as-is while picking
  # catppuccin-latte flips them to the light variant below.
  modeCases = lib.concatMapStringsSep "\n" (name:
    let p = themes.themes.${name}; in
    ''      ${name}) TERM_MODE=${p.mode} ;;''
  ) themeNames;

  # Catppuccin Latte, the only light option today — foot has no built-in
  # named schemes so its palette is spelled out; wezterm and ghostty ship
  # "Catppuccin Latte" as a bundled theme name.
  weztermTerminalThemes = {
    dark = "return nil\n";
    light = ''return "Catppuccin Latte"'' + "\n";
  };

  # foot's palettes live directly in modules/terminals/foot.nix as static
  # [colors-dark]/[colors-light] sections; this file only persists which one
  # new windows should start in (SIGUSR1/SIGUSR2 flip already-open windows).
  footTerminalThemes = {
    dark = "initial-color-theme=dark\n";
    light = "initial-color-theme=light\n";
  };

  ghosttyTerminalThemes = {
    dark = "";
    light = ''
      theme = Catppuccin Latte
      cursor-color = #1e66f5
    '';
  };

  themeSwitchScript = ''
    #!/usr/bin/env bash
    set -euo pipefail

    STATE_DIR="$HOME/.local/state/theme-switcher"
    STATE_FILE="$STATE_DIR/current"
    WAYBAR_THEMES="$HOME/.config/waybar/themes"
    WOFI_THEMES="$HOME/.config/wofi/themes"
    WEZTERM_THEMES="$HOME/.config/wezterm/themes"
    FOOT_THEMES="$HOME/.config/foot/themes"
    GHOSTTY_THEMES="$HOME/.config/ghostty/themes"
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

    case "$THEME" in
    ${modeCases}
      *) TERM_MODE="dark" ;;
    esac

    cp --remove-destination "$WEZTERM_THEMES/$TERM_MODE.lua" "$HOME/.config/wezterm/current-theme.lua"
    cp --remove-destination "$FOOT_THEMES/$TERM_MODE.ini" "$HOME/.config/foot/current-theme.ini"
    if [ "$TERM_MODE" = "light" ]; then
      pkill -SIGUSR2 foot 2>/dev/null || true
    else
      pkill -SIGUSR1 foot 2>/dev/null || true
    fi
    cp --remove-destination "$GHOSTTY_THEMES/$TERM_MODE.conf" "$HOME/.config/ghostty/current-theme"

    if [ -n "$B1" ]; then
      hyprctl keyword general:col.active_border "rgba(''${B1}ff) rgba(''${B2}ff) 45deg" 2>/dev/null || true
      hyprctl keyword general:col.inactive_border "rgb($INA)" 2>/dev/null || true
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
    ".config/wezterm/themes/dark.lua".text = weztermTerminalThemes.dark;
    ".config/wezterm/themes/light.lua".text = weztermTerminalThemes.light;
    ".config/foot/themes/dark.ini".text = footTerminalThemes.dark;
    ".config/foot/themes/light.ini".text = footTerminalThemes.light;
    ".config/ghostty/themes/dark.conf".text = ghosttyTerminalThemes.dark;
    ".config/ghostty/themes/light.conf".text = ghosttyTerminalThemes.light;
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
