{ pkgs, username, homeDirectory, ... }:

{
  home = {
    username = "${username}";
    homeDirectory = "${homeDirectory}";
    sessionVariables.EDITOR = "nvim";
    sessionPath = [
      "${homeDirectory}/.nix-profile/bin"
    ];
    stateVersion = "25.05";
    packages = with pkgs; [
      bat
      bc
      file
      git
      htop-vim
      jdk21
      jq
      nmon
      pstree
      superfile
      tree
      unzip
    ];
  };
  programs = {
    home-manager.enable = true;
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      useTheme = "sorin";
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    vim = {
      enable = true;
    };
  };
  systemd.user = {
    timers."minecraft-backup" = {
      Install.WantedBy = [ "default.target" ];
      Timer = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "minecraft-backup.service";
      };
    };
    services."minecraft-backup" = {
      Install.WantedBy = [ "default.target" ];
      Unit = {
        Description = "Backup Minecraft";
      };
      Service = {
        Type = "oneshot";
        WorkingDirectory = "${homeDirectory}";
        ExecStart = "/run/current-system/sw/bin/snapshot-world ${homeDirectory}/direwolf/1.21/1.14.2/world";
      };
    };
  };
}
