# Registers an "Omarchy 4" entry in GDM's session list, next to Hyprland /
# Hyprland (uwsm) / Niri / Omarchy. GDM only reads wayland-session .desktop
# files from packages in services.displayManager.sessionPackages, so the
# entry has to live system-side even though the config it launches is all
# home-manager (see ../omarchy4-session.nix).
#
# The Exec is the fixed path to the home-manager-managed launcher, which
# sets OMARCHY_PATH + XDG_CONFIG_HOME=~/.config-omarchy4 and starts Hyprland.
#
# This is always registered (cheap — just a .desktop file). The session only
# does anything once `enableOmarchy4Session` in ../flake.nix has put the
# launcher + config tree in place via `hm`.

{ pkgs, ... }:

let
  omarchy4Desktop = pkgs.writeText "omarchy4.desktop" ''
    [Desktop Entry]
    Name=Omarchy 4
    Comment=Upstream Omarchy 4 (Quattro) on Hyprland — isolated ~/.config-omarchy4
    Exec=/home/runih/.local/bin/omarchy4-session
    Type=Application
    DesktopNames=Hyprland
    Keywords=tiling;wayland;compositor;omarchy;quattro;
  '';

  omarchy4Session = pkgs.runCommand "omarchy4-session"
    { passthru.providedSessions = [ "omarchy4" ]; }
    ''
      install -Dm444 ${omarchy4Desktop} $out/share/wayland-sessions/omarchy4.desktop
    '';
in
{
  services.displayManager.sessionPackages = [ omarchy4Session ];
}
