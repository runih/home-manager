{ pkgs, ... }:

let
  rpi5Repo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "raspberry-pi5-leds";
    rev = "4b0c610468b3e1eced27074e2a93de77c5c608a3";
    hash = "sha256-+MJY6/RfTFzn6xRmBQCJbXBdZsHC0CGy+Qlh80+SXZw=";
  };

  rxtxLED = pkgs.stdenv.mkDerivation {
    name = "rxtx-led";
    src = rpi5Repo;
    buildInputs = [ pkgs.gcc ];
    buildPhase = ''
      g++ -std=c++17 -O2 $src/rxtx_led.cpp -o rxtx-led
      gcc -o disk_io_led_monitor disk_io_led_monitor.c -lpthread
      strip rxtx-led disk_io_led_monitor
    '';
    installPhase = ''
      install -Dm755 rxtx-led $out/bin/rxtx-led
      install -Dm755 disk_io_led_monitor $out/bin/disk_io_led_monitor
    '';
  };
in
{
  environment.systemPackages = [ rxtxLED ];


  systemd.services.rxtx-led = {
    description = "Raspberry Pi 5 Network LED Monitor";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/rxtx-led enu1c4i2";
    };
  };

  systemd.services.disk-io-led = {
    description = "Raspberry Pi 5 Disk IO LED Monitor";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/disk_io_led_monitor nvme0n1";
    };
  };
}
