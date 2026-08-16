{ config, lib, pkgs, ... }:

with lib;

{
  options.ollama = {
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address `ollama serve` binds to. Use \"0.0.0.0\" to accept connections from other machines on the LAN (e.g. Open WebUI running elsewhere).";
    };

    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Port `ollama serve` listens on.";
    };
  };

  config = {
    home.packages = [ pkgs.ollama ];

    launchd.agents.ollama = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
        RunAtLoad = true;
        KeepAlive = true;
        EnvironmentVariables = {
          OLLAMA_HOST = "${config.ollama.host}:${toString config.ollama.port}";
        };
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ollama.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ollama.error.log";
      };
    };
  };
}
