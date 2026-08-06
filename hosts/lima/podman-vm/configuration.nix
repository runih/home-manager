{ pkgs, ... }:

{
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    podman-compose
  ];

  # Podman — rootful socket is forwarded to the macOS host by lima-container module.
  # Connect from macOS via DOCKER_HOST / CONTAINER_HOST (set by modules/tools/lima.nix).
  virtualisation.podman = {
    enable         = true;
    dockerCompat   = true;   # allows `docker` CLI to work against Podman
    dockerSocket.enable = true;
  };

  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
}
