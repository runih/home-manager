# Login / display manager for macnix.
#
# ┌─ useGreetd = true  → greetd + tuigreet (TTY greeter, no GNOME stack)
# └─ useGreetd = false → GDM (the previous setup)
#
# Getting GDM back if greetd misbehaves:
#   * Fastest: reboot and pick the previous NixOS generation in the
#     bootloader menu — it still runs GDM. Nothing here is permanent until
#     you `nixos-switch` again.
#   * Permanent: set `useGreetd = false` below, then from a TTY
#     (Ctrl+Alt+F2, log in) run `nixos-switch`. TTY logins keep working
#     even if the greeter is completely broken.
#
# The Wayland session list (Hyprland, Hyprland (uwsm), Niri, Omarchy,
# GNOME) is the same either way — both read
# services.displayManager.sessionPackages.

{ lib, pkgs, config, ... }:

let
  useGreetd = true;

  waylandSessions =
    "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in
{
  # Default highlighted session in the greeter.
  services.displayManager.defaultSession = "hyprland";

  # Keep the GNOME session selectable as a fallback. (Drop this line later
  # for a lighter closure once greetd feels solid — the session list still
  # has the tiling compositors without it.)
  services.desktopManager.gnome.enable = true;

  # GNOME would otherwise pull GDM back in as mkDefault.
  services.displayManager.gdm.enable = lib.mkForce (!useGreetd);

  services.greetd = lib.mkIf useGreetd {
    enable = true;
    settings.default_session = {
      command = lib.concatStringsSep " " [
        "${pkgs.greetd.tuigreet}/bin/tuigreet"
        "--time"
        "--remember"            # prefill last username
        "--remember-session"    # and reselect its last session
        "--asterisks"
        "--sessions ${waylandSessions}"
      ];
      user = "greeter";
    };
  };

  # Let gnome-keyring unlock at login under greetd (GDM did this for us).
  security.pam.services.greetd.enableGnomeKeyring = lib.mkIf useGreetd true;
}
