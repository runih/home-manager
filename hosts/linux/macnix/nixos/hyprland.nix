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
    etc = {
      "X11/xkb/symbols/custommac" = {
        source = "/home/runih/.config/home-manager/custom_mac_se";
      };
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  fonts.packages = with pkgs; [ font-awesome ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
  };
}
