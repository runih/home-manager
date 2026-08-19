{ ... }:

{
  # Swedish Mac keyboard layout, consolidated: console, X11/XKB, and the
  # custom XKB symbol file all need to agree for keys to land correctly.
  console.keyMap = "sv-latin1";

  services.xserver.xkb = {
    layout = "se";
    variant = "mac";
  };

  environment.etc = {
    "X11/xkb/symbols/custommac" = {
      source = "/home/runih/.config/home-manager/custom_mac_se";
    };
  };
}
