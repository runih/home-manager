{ pkgs, pkgs-unstable, ... }:

{
  programs = {
    nix-ld = {
      enable = true;
    };
    firefox.enable = true;
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
      # Latest Hyprland (0.56.2) from nixpkgs-unstable — nixos-26.05 only has
      # 0.55.4. 0.56 shipped with no breaking config changes, and the
      # hyprexpo plugin (hosts/linux/macnix/hyprland.nix) is bumped to match.
      package = pkgs-unstable.hyprland;
      portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
    };
    niri = {
      enable = true;
    };
    dms-shell = {
      enable = true;
      systemd.enable = true;
      plugins = {
        DockerManager = {
          src = pkgs.fetchFromGitHub {
            owner = "LuckShiba";
            repo = "DmsDockerManager";
            rev = "860457bbb043a6651a2cbafe6e77d443123a0b07";
            hash = "sha256-VoJCaygWnKpv0s0pqTOmzZnPM922qPDMHk4EPcgVnaU=";
          };
        };
      };
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # wireshark = {
    #   enable = true;                  # Enable Wireshark
    #   # runAsRoot = false;              # Do not run Wireshark as root
    #   # extraGroups = [ "wireshark" ];  # Add user to the wireshark group for permissions
    #   dumpcap.enable = true;          # Enable dumpcap for packet capturing
    # };
  };
}
