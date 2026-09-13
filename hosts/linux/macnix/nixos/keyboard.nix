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

  # This external USB keyboard (a Vortex Pok3r, vendor:product 04d9:0207)
  # reports its physical Right Shift key with the raw HID scan code that
  # Linux's default hid-generic keycode table maps to KEY_UP, not
  # KEY_RIGHTSHIFT — confirmed with `evtest`: pressing that key emits
  # `MSC_SCAN value 70052` (hex 111a4) followed by `KEY_UP`. This is a
  # kernel-level miskeying, upstream of XKB entirely (no kb_layout/
  # kb_options change can fix it — those only remap already-correct
  # evdev keycodes). Fix it at the source with a udev hwdb keycode
  # override; syntax and match-string format per
  # nixpkgs' systemd's own lib/udev/hwdb.d/60-keyboard.hwdb.
  services.udev.extraHwdb = ''
    evdev:input:b0003v04D9p0207*
     KEYBOARD_KEY_111a4=rightshift
  '';
}
