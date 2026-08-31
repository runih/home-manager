{ config, lib, pkgs, ... }:
let
  # Maps ~/.ssh/<file> to its pass-store entry under ssh/.
  files = {
    "config"          = "ssh/config";
    "esh_config"      = "ssh/esh_config";
    "kyrkan_config"   = "ssh/kyrkan_config";
  };

  mkWrite = target: entry: ''
    ${pkgs.pass}/bin/pass show ${entry} > "$HOME/.ssh/${target}.new"
    chmod 600 "$HOME/.ssh/${target}.new"
    mv -f "$HOME/.ssh/${target}.new" "$HOME/.ssh/${target}"
  '';
in
{
  home.activation.ssh_config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 "$HOME/.ssh"
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkWrite files)}
  '';
}
