{ pkgs, homeDirectory, ... }:

let
  vmName     = "podman-vm";
  vmFlake    = "${homeDirectory}/.config/home-manager/hosts/lima/podman-vm";
  socketPath = "${homeDirectory}/.lima/${vmName}/sock/docker.sock";

  # Build the NixOS QCOW2 on a Linux aarch64 builder and start the Lima VM.
  # The image is built once; subsequent starts use limactl directly.
  startScript = pkgs.writeShellApplication {
    name = "lima-podman-start";
    runtimeInputs = [ pkgs.lima pkgs.nix ];
    text = ''
      set -euo pipefail
      FLAKE="${vmFlake}"
      VM="${vmName}"

      if limactl list "$VM" --format '{{.Name}}' 2>/dev/null | grep -q "^$VM$"; then
        echo "==> Starting existing VM $VM"
        limactl start "$VM"
      else
        echo "==> Building NixOS image (requires aarch64-linux builder)..."
        IMAGE_DIR=$(nix build "$FLAKE#packages.aarch64-linux.default" --print-out-paths --no-link)
        IMAGE=$(find "$IMAGE_DIR" -name "*.qcow2" | head -1)
        echo "==> Image built: $IMAGE"
        echo "==> Creating Lima VM $VM"
        limactl create \
          --name "$VM" \
          --set ".images = [{\"location\": \"$IMAGE\", \"arch\": \"aarch64\"}]" \
          "$FLAKE/lima.yaml"
        limactl start "$VM"
      fi
    '';
  };
in {
  home.packages = with pkgs; [
    lima
    startScript
  ];

  # Point both CONTAINER_HOST and DOCKER_HOST at the Lima VM's Podman socket.
  home.sessionVariables = {
    CONTAINER_HOST = "unix://${socketPath}";
    DOCKER_HOST    = "unix://${socketPath}";
  };

  home.shellAliases = {
    lima-podman-start = "lima-podman-start";
    lima-podman-stop  = "limactl stop ${vmName}";
    lima-podman-ssh   = "limactl shell ${vmName}";
  };
}
