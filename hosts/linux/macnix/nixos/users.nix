{ pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.runih = {
    isNormalUser = true;
    description = "Rúni H.Hansen";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" ];
    # packages = with pkgs; [
    # #  thunderbird
    # ];
    shell = pkgs.zsh;
  };

}
