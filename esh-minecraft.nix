{ pkgs, ...  }:
{
  home = {
    packages = with pkgs; [
      rdiff-backup
      superfile
    ];
  };

  systemd.user = {
    timers."minecraft-backup" = {
      Install.WantedBy = [ "default.target" ];
      Timer = {
        OnBootSec = "15m";
        OnUnitActiveSec = "15m";
        Unit = "minecraft-backup.service";
      };
    };
    services."minecraft-backup" = {
      Install.WantedBy = [ "default.target" ];
      Unit = {
        Description = "Backup Vanilla Minecraft";
      };
      Service = {
        Type = "oneshot";
        WorkingDirectory = "/home/runih";
        ExecStart = toString(
          pkgs.writeShellScript "minecraft-backup-script" ''
          #!/usr/bin/env bash
          /home/runih/.nix-profile/bin/rdiff-backup --new backup $HOME/minecraft/world $HOME/backup/minecraft
          ''
        );
      };
    };
  };
}
