{ pkgs, ... }:
let
  rpi5Repo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "raspberry-pi5-leds";
    rev = "da9811b6e583b26663aae360b5484805eaff253d";
    hash = "sha256-7Jr3iviHDfx4ZVTvPbrpK3+fcBu29rDl1y1Lf89HKsE=";
  };
  rxtxLED = rpi5Repo + "/rxtx_led.sh";
in
  {
  home.file = {
    "bin/rxtx-led".source = rxtxLED;
  };
}
