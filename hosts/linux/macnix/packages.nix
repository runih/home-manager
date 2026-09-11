# Home-manager packages for macnix that don't fit a shared module in
# modules/default.nix — either pulled from nixpkgs-unstable (see
# CLAUDE.md's "Unstable packages" section) or a one-off flake input
# (zen-browser).
{ zen-browser, lib, enableOmarchy }:
{ pkgs, pkgsUnstable, ... }:

{
  # `gh` from unstable is dropped when omarchy is on — its git.nix
  # enables `programs.gh` (stable), and two gh's collide in the profile.
  home.packages = [
    zen-browser.packages."x86_64-linux".default
    pkgsUnstable.claude-code
    pkgsUnstable.ollama
    pkgs.wdisplays
  ] ++ lib.optional (!enableOmarchy) pkgsUnstable.gh;
}
