{ nixpkgs, home-manager }:
{ system, username, homeDirectory, modules, pkgs ? nixpkgs.legacyPackages.${system} }:
home-manager.lib.homeManagerConfiguration {
  inherit pkgs modules;
  extraSpecialArgs = { inherit username homeDirectory; };
}
