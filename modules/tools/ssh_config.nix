{ config, lib, pkgs, ... }:
let
  # Maps ~/.ssh/<file> to its pass-store entry under ssh/.
  files = {
    "config"          = "ssh/config";
    "esh_config"      = "ssh/esh_config";
    "kyrkan_config"   = "ssh/kyrkan_config";
  };

  # Entry used to probe whether pass can decrypt without a prompt.
  probeEntry = "ssh/config";

  mkWrite = target: entry: ''
    if ${pkgs.pass}/bin/pass show ${entry} > "$HOME/.ssh/${target}.new" 2>/dev/null; then
      chmod 600 "$HOME/.ssh/${target}.new"
      mv -f "$HOME/.ssh/${target}.new" "$HOME/.ssh/${target}"
    else
      rm -f "$HOME/.ssh/${target}.new"
      echo "ssh_config: could not read ${entry} from pass; kept existing ~/.ssh/${target}"
    fi
  '';
in
{
  home.activation.ssh_config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 "$HOME/.ssh"

    # Only refresh the SSH config files if `pass` can already decrypt without
    # prompting -- i.e. the GPG passphrase is still cached in gpg-agent from an
    # earlier `pass` unlock. `--pinentry-mode cancel` makes gpg fail straight
    # away instead of popping a pinentry in the middle of `hm`.
    if PASSWORD_STORE_GPG_OPTS="--pinentry-mode cancel" \
        ${pkgs.pass}/bin/pass show ${probeEntry} >/dev/null 2>&1; then
      ${lib.concatStringsSep "\n      " (lib.mapAttrsToList mkWrite files)}
    else
      echo "ssh_config: pass is locked -- skipping ~/.ssh config refresh."
      echo "ssh_config: run 'pass show ${probeEntry}' to unlock, then re-run hm."
    fi
  '';
}
