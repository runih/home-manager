{ ... }:

{
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      settings = {
        ClientAliveInterval = 25;
        ClientAliveCountMax = 3;
      };
    };
    usbmuxd.enable = true;
    uptimed.enable = true;
    pcscd.enable = true;
    kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [ "end0" ];
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        subnet4 = [
          {
            id = 1;
            pools = [
              {
                pool = "172.16.7.5 - 172.16.7.12";
              }
            ];
            subnet = "172.16.7.0/28";
            option-data = [
              {
                name = "routers";
                data = "172.16.7.1";
              }
            ];
          }
        ];
        valid-lifetime = 4000;
      };
    };
  };
}
