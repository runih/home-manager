{ nixpkgs, home-manager }:
{ system
, username
, homeDirectory
, modules
, allowUnfree ? false
, nixpkgsUnstable ? null
, pkgs ? (if allowUnfree
    then import nixpkgs { inherit system; config.allowUnfree = true; }
    else nixpkgs.legacyPackages.${system})
}:
let
  pkgsUnstable =
    if nixpkgsUnstable == null
    then null
    else import nixpkgsUnstable { inherit system; config.allowUnfree = true; };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs modules;
  extraSpecialArgs = { inherit username homeDirectory pkgsUnstable; };
}
