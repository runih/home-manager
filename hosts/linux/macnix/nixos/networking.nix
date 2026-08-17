{ ... }:

{
  networking = {
    hostName = "macnix"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    firewall = {
      enable = true;
      # Open ports in the firewall.
      allowedTCPPorts = [ 22 5173 8080 ];
      # allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
    };
  };
}
