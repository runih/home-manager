{ config, lib, ... }:

{
  documentation.enable = false;

  lima.vmName = "podman-vm";

  lima.settings.ssh.localPort = 2223;
  lima.settings.cpus          = lib.mkDefault 2;
  lima.settings.memory        = lib.mkDefault "4GiB";
  lima.settings.disk          = lib.mkDefault "50GiB";

  lima.settings.mounts = [
    {
      location = "/Users/runih";
      writable  = true;
    }
    {
      location  = "/tmp/lima";
      writable  = true;
    }
  ];

  virtualisation.containers.registries.search = [
    "docker.io"
    "quay.io"
    "ghcr.io"
  ];

  networking.firewall.enable = false;
}
