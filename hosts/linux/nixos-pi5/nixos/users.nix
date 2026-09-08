{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell=pkgs.zsh;

    groups.minecraft = {
      members = [
        "runih"
      ];
    };

    users = {
      runih = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQFY9gJBBNF0/gHo/R9LaRNQG03SHB2JHlrswRXRyMk runih@BlackMac.local"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3uLFTCfWmf1HtJnPi144wheHxFPmCNvL9iiGgvgQrC runih@Okkara-iMac.home.okkara.net"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFyqiCskpc9c5uI6c/ms6A8Tkd+sk/T+tvEfkQkRvDa runih@nixos"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIg3ktZhgIzKA2DqA0nmSdJB5baMWuBZFCCD7klOFj1p runih@macnix"
        ];
        #packages = with pkgs; [ ];
      };

      minecraft = {
        group = "minecraft";
        isNormalUser = true;
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQFY9gJBBNF0/gHo/R9LaRNQG03SHB2JHlrswRXRyMk runih@BlackMac.local"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3uLFTCfWmf1HtJnPi144wheHxFPmCNvL9iiGgvgQrC runih@Okkara-iMac.home.okkara.net"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFyqiCskpc9c5uI6c/ms6A8Tkd+sk/T+tvEfkQkRvDa runih@nixos"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIg3ktZhgIzKA2DqA0nmSdJB5baMWuBZFCCD7klOFj1p runih@macnix"
        ];
      };
    };
  };
}
