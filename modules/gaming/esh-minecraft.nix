{ pkgs, homeDirectory, ...  }:
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
        WorkingDirectory = "{homeDirectory}";
        ExecStart = toString(
          pkgs.writeShellScript "minecraft-backup-script" ''
          #!/usr/bin/env bash
          ${homeDirectory}/.nix-profile/bin/rdiff-backup --new backup ${homeDirectory}/minecraft/world ${homeDirectory}/backup/minecraft
          ''
        );
      };
    };
  };
}
