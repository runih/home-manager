{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      pass
    ];
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
      pinentry.package = pkgs.pinentry-curses;
      enableScDaemon = false;
    };
  };
}
