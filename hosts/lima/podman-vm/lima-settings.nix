{ config, lib, ... }:

{
  documentation.enable = false;

  lima.vmName = "podman-vm";
  lima.user.name = "runih";

  lima.settings.ssh.localPort = 2223;
  lima.settings.cpus          = lib.mkDefault 2;
  lima.settings.memory        = lib.mkDefault "4GiB";
  lima.settings.disk          = lib.mkDefault "50GiB";

  lima.settings.mounts = [
    {
      location = "/Users/runih";
      writable  = true;
    }
  ];

  # Forward the rootful Podman socket to the macOS host.
  lima.settings.portForwards = [
    {
      guestSocket = "/run/podman/podman.sock";
      hostSocket  = "{{.Dir}}/sock/docker.sock";
    }
  ];

  # SSH key injection: Lima drops its cloud-init user-data into the CIDATA
  # volume; cloud-init reads it and populates ~/.ssh/authorized_keys.
  services.cloud-init = {
    enable         = true;
    network.enable = true;
  };

  virtualisation.containers.registries.search = [
    "docker.io"
    "quay.io"
    "ghcr.io"
  ];

  networking.firewall.enable = false;
}
