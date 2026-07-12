{ pkgs, ... }:

{
  home.packages = with pkgs; [
    podman
    lazydocker
  ];
}
