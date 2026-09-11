# Registers an "Omarchy" entry in GDM's session list, next to Hyprland /
# Hyprland (uwsm) / Niri. GDM only reads wayland-session .desktop files
# from packages in services.displayManager.sessionPackages (not from
# ~/.local/share), so the entry has to live system-side even though the
# actual config it launches is all home-manager (see
# ../omarchy-session.nix).
#
# The Exec is the fixed path to the home-manager-managed launcher script,
# which sets XDG_CONFIG_HOME=~/.config-omarchy and starts Hyprland.

{ pkgs, ... }:

let
  omarchyDesktop = pkgs.writeText "omarchy.desktop" ''
    [Desktop Entry]
    Name=Omarchy
    Comment=Omarchy (omarchy-nix) desktop on Hyprland — isolated ~/.config-omarchy
    Exec=/home/runih/.local/bin/omarchy-hyprland
    Type=Application
    DesktopNames=Hyprland
    Keywords=tiling;wayland;compositor;omarchy;
  '';

  omarchySession = pkgs.runCommand "omarchy-session"
    { passthru.providedSessions = [ "omarchy" ]; }
    ''
      install -Dm444 ${omarchyDesktop} $out/share/wayland-sessions/omarchy.desktop
    '';
in
{
  services.displayManager.sessionPackages = [ omarchySession ];
}
