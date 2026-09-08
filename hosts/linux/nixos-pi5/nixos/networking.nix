{ ... }:

{
  networking = {
    hostName = "nixos-pi5"; # Define your hostname.

    interfaces = {
      end0.ipv4.addresses = [
        { 
          address = "172.16.7.1";
          prefixLength = 28;
        }
      ];
    };

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 67 68 3128 3000 5173 8080 25565 ];
      allowedUDPPorts = [ 67 68 ];
      # Or disable the firewall altogether.
      extraCommands = ''
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -i end0 -j ACCEPT
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

        iptables -t nat -A POSTROUTING -o enu1c4i2 -j MASQUERADE
        iptables -A FORWARD -i enu1c4i2 -o end0 -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -A FORWARD -i end0 -o enu1c4i2 -j ACCEPT
        iptables -t nat -A POSTROUTING -o enu1c4i2 -j MASQUERADE
      
        iptables -t nat -A POSTROUTING -o bnep0 -j MASQUERADE
        iptables -A FORWARD -i bnep0 -o end0 -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -A FORWARD -i end0 -o bnep0 -j ACCEPT
        iptables -t nat -A POSTROUTING -o bnep0 -j MASQUERADE
      '';
    };

    # Pick only one of the below networking options.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };
}
