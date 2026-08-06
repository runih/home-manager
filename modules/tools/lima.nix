{ pkgs, homeDirectory, ... }:

let
  vmName     = "podman-vm";
  socketPath = "${homeDirectory}/.lima/${vmName}/sock/docker.sock";
in {
  home.packages = with pkgs; [
    lima
  ];

  # Point both CONTAINER_HOST and DOCKER_HOST at the Lima VM's Podman socket.
  # The socket is forwarded to the host automatically by the lima-container NixOS module.
  # Start / stop the VM with: nix run ~/.config/home-manager/hosts/lima/podman-vm#podman-vm -- start|stop
  home.sessionVariables = {
    CONTAINER_HOST = "unix://${socketPath}";
    DOCKER_HOST    = "unix://${socketPath}";
  };

  home.shellAliases = {
    lima-podman-start = "nix run ~/.config/home-manager/hosts/lima/podman-vm#podman-vm -- start";
    lima-podman-stop  = "nix run ~/.config/home-manager/hosts/lima/podman-vm#podman-vm -- stop";
    lima-podman-ssh   = "limactl shell podman-vm";
  };
}
