{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313
    python313Packages.dnspython
    python313Packages.asyncio-dgram
    python313Packages.mcstatus
    (writeShellScriptBin "create-subvolume" ''
      #!/usr/bin/env bash

      # Get the frist argument as the subvolume name and make sure it is absolute path is in the $SUDO_USER home folder
      SUBVOLUME_NAME="$1"
      if [[ -z "$SUBVOLUME_NAME" ]]; then
        echo "Usage: $0 <subvolume_name>"
        exit 1
      fi
      SUBVOLUME_PATH="/home/$SUDO_USER/$SUBVOLUME_NAME"
      # Create the subvolume
      btrfs subvolume create "$SUBVOLUME_PATH"
      # change the owner to the same as the $SUDO_USER home folder, get the permission from the home folder
      chown -R "$(stat -c '%U:%G' /home/$SUDO_USER)" "$SUBVOLUME_PATH"
      chmod g+ws "$SUBVOLUME_PATH"
      echo "Subvolume created at $SUBVOLUME_PATH"
    '')
    (writeShellScriptBin "snapshot-world" ''
      #!/usr/bin/env bash
      export PATH=/run/current-system/sw/bin:/usr/bin:/bin

      if ! pgrep -x java > /dev/null ; then
        echo "Minecraft server is not running. Exiting."
        exit 0
      fi

      if [[ -z "$1" ]]; then
        echo "Usage: $0 <world_path>"
        exit 1
      fi
      if [ ! -d /run/user/$(id -u)/minecraft ]; then
        mkdir -p /run/user/$(id -u)/minecraft
        chown "$(id -u):$(id -g)" /run/user/$(id -u)/minecraft
      fi
      if [ -f /run/user/$(id -u)/minecraft/players ]; then
        cat /run/user/$(id -u)/minecraft/players > /run/user/$(id -u)/minecraft/do_snapshot
      else
        echo 0 > /run/user/$(id -u)/minecraft/do_snapshot
      fi
      # Check if there are any players online
      mcstatus 192.168.7.9 status | awk '(match($2, /^[0-9]/, arr)) $0 ~ /players:/  {print arr[0]}' > /run/user/$(id -u)/minecraft/players

  
      if [ "$(cat /run/user/$(id -u)/minecraft/do_snapshot)" != "0" ]; then
        WORLD_PATH=$(readlink -f "$1")
        SNAPSHOT=$(dirname "$WORLD_PATH")/$(date +"%Y%m%d_%H%M")
        btrfs subvolume snapshot "$WORLD_PATH" "$SNAPSHOT"
      else
        echo "No players online. Skipping snapshot."
      fi
    '')
  ];

  security.sudo.extraRules = [
    {
      users = [ "minecraft" ];
      commands = [
      {
        command = "/run/current-system/sw/bin/create-subvolume";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/snapshot-world";
        options = [ "NOPASSWD" ];
      }
      ];
    }
  ];
}
