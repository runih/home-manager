{ pkgs, homeDirectory, ... }:

let
  vmName     = "podman-vm";
  vmFlake    = "${homeDirectory}/.config/home-manager/hosts/lima/podman-vm";
  socketPath = "${homeDirectory}/.lima/${vmName}/sock/docker.sock";
  nixosLima  = "nix run github:ciderale/nixos-lima#nixos-lima --";
in {
  home.packages = with pkgs; [
    lima
    podman       # remote client — connects via CONTAINER_HOST socket
    lazydocker   # TUI for containers
  ];

  # Point both CONTAINER_HOST and DOCKER_HOST at the Lima VM's Podman socket.
  home.sessionVariables = {
    CONTAINER_HOST = "unix://${socketPath}";
    DOCKER_HOST    = "unix://${socketPath}";
  };

  home.shellAliases = {
    # Bootstrap: one-time Ubuntu download + nixos-anywhere install (~5 min, no builder needed).
    # After the VM runs NixOS, subsequent starts use limactl start directly.
    lima-podman-start = "${nixosLima} ${vmFlake}#${vmName} start";
    lima-podman-stop  = "limactl stop ${vmName}";
    lima-podman-ssh   = "limactl shell ${vmName}";
  };
}
