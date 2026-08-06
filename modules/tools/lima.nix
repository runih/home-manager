{ pkgs, homeDirectory, ... }:

let
  vmName     = "podman-vm";
  vmFlake    = "${homeDirectory}/.config/home-manager/hosts/lima/podman-vm";
  socketPath = "${homeDirectory}/.lima/${vmName}/sock/docker.sock";
  nixosLima  = "nix run github:ciderale/nixos-lima#nixos-lima --";
in {
  home.packages = with pkgs; [
    lima
  ];

  # Point both CONTAINER_HOST and DOCKER_HOST at the Lima VM's Podman socket.
  # The socket is forwarded to the host automatically by the lima-container NixOS module.
  home.sessionVariables = {
    CONTAINER_HOST = "unix://${socketPath}";
    DOCKER_HOST    = "unix://${socketPath}";
  };

  home.shellAliases = {
    lima-podman-start = "${nixosLima} ${vmFlake}#${vmName} start";
    lima-podman-stop  = "${nixosLima} ${vmFlake}#${vmName} stop";
    lima-podman-ssh   = "limactl shell ${vmName}";
  };
}
