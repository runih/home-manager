{ ... }:

{
  # Swedish Mac keyboard layout. macnix-se wraps the stock se(mac) variant
  # and corrects a hardware keycode swap specific to this MacBook's
  # internal keyboard — see ./custom_mac_se for details. extraLayouts also
  # exports XKB_CONFIG_ROOT session-wide, which is what makes niri and
  # Hyprland (Wayland, not just X11) pick this layout up too.
  #
  # console.keyMap is unaffected by XKB, so the swap still applies at the
  # Linux console/TTY.
  console.keyMap = "sv-latin1";

  services.xserver.xkb = {
    layout = "macnix-se";
    extraLayouts.macnix-se = {
      description = "Swedish (Macintosh, internal keyboard fix)";
      languages = [ "swe" ];
      symbolsFile = ./custom_mac_se;
    };
  };
}
