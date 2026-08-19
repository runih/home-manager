{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      dunst
      kitty
      libnotify
      networkmanagerapplet
      rofi
      awww
      waybar
    ];

    sessionVariables = { NIXOS_OZONE_WL = "1"; };
  };

  fonts.packages = with pkgs; [ font-awesome ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
  };
}
