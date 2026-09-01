# Omarchy system-level desktop (opt-in) — NOT imported unless the
# `enableOmarchy` toggle in ./flake.nix is flipped to true.
#
# This is the system half of the macnix Omarchy experiment. The
# home-manager half lives in ../flake.nix (its own `enableOmarchy`). Enable
# BOTH together, or neither — omarchy-nix expects its NixOS and
# home-manager modules to run as a pair.
#
# omarchy-nix (github:henrysipp/omarchy-nix) reimplements DHH's Omarchy for
# NixOS. It is opinionated and assumes it owns the desktop, so the current
# macnix config conflicts with it in several places you must resolve before
# `nixos-switch` will succeed:
#
#   - nixos/services.nix: GDM + GNOME + `defaultSession = "hyprland"`.
#     Omarchy brings greetd + tuigreet. Two display managers do not
#     coexist — remove the GDM/GNOME block (or the gnome desktopManager)
#     when Omarchy is on.
#   - nixos/programs.nix: `programs.hyprland.enable` (from nixpkgs) and
#     `programs.niri.enable`. Omarchy re-points `programs.hyprland.package`
#     at its own flake (Hyprland built against nixos-unstable), so expect
#     version skew against the pinned nixos-26.05 xdg-desktop-portal /
#     mesa / qt packages. `dms-shell` overlaps too.
#   - nixos/desktop.nix: waybar / rofi / dunst / awww / networkmanagerapplet
#     are installed system-wide; the Omarchy home-manager module ships and
#     configures its own copies.
#   - pipewire, bluetooth and NetworkManager are configured both here and
#     by omarchy's system.nix — NixOS will flag duplicate non-mergeable
#     option definitions. Pick one owner for each.
#
# Omarchy also pulls `claude-code` / unfree packages; `allowUnfree` is
# already set in nixos/configuration.nix.

{ omarchy-nix, ... }:

{
  imports = [ omarchy-nix.nixosModules.default ];

  omarchy = {
    full_name = "Rúni H.Hansen";
    email_address = "runi.hansen@okkara.net";
    theme = "tokyo-night";
    scale = 2; # MacBook10,1 HiDPI panel
  };
}
