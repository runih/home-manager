{
  description = "Home Manager configuration of runih";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hosts - Linux
    macnix.url = "path:./hosts/linux/macnix";
    nixos-pi5.url = "path:./hosts/linux/nixos-pi5";
    nixos.url = "path:./hosts/linux/nixos";
    nixos2.url = "path:./hosts/linux/nixos2";
    madakara-nixos.url = "path:./hosts/linux/madakara-nixos";

    # Hosts - macOS
    BlackMac.url = "path:./hosts/mac/BlackMac";
    MaikensMacbook.url = "path:./hosts/mac/MaikensMacbook";
    iMac.url = "path:./hosts/mac/iMac";
  };

  outputs = { macnix, nixos-pi5, nixos, nixos2, madakara-nixos, BlackMac, MaikensMacbook, iMac, ... }:
    {
      homeConfigurations = {
        # macOS hosts
        "runih@BlackMac"              = BlackMac.outputs.homeConfigurations.BlackMac;
        "maiken@MaikensMacbook.local" = MaikensMacbook.outputs.homeConfigurations.MaikensMacbook;
        "runih@iMac.home.okkara.net"  = iMac.outputs.homeConfigurations.iMac;

        # Linux hosts
        "runih@macnix"        = macnix.outputs.homeConfigurations.macnix;
        "runih@nixos-pi5"     = nixos-pi5.outputs.homeConfigurations.nixos-pi5;
        "minecraft@nixos-pi5" = nixos-pi5.outputs.homeConfigurations.minecraft;
        "runih@nixos"         = nixos.outputs.homeConfigurations.nixos;
        "runih@nixos2"        = nixos2.outputs.homeConfigurations.nixos2;
        "runih@madakara-nixos" = madakara-nixos.outputs.homeConfigurations.madakara-nixos;
      };
    };
}
