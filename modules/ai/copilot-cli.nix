{ config, lib, pkgs, ... }:

with lib;

{
  options.copilotCli = {
    model = mkOption {
      type = types.str;
      default = "claude-opus-4.6";
      description = "Default AI model for Copilot CLI.";
    };

    effortLevel = mkOption {
      type = types.str;
      default = "high";
      description = "Reasoning effort level.";
    };

    allowedUrls = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "URLs allowed for web access.";
    };

    hooks = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra `hooks` entries merged into ~/.copilot/settings.json.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional settings merged into ~/.copilot/settings.json.";
    };
  };

  config = {
    home.packages = [ pkgs.jq ];

    home.file.".copilot/statusline-command.sh" = {
      source = ./copilot-cli-statusline.sh;
      executable = true;
    };

    home.file.".copilot/settings.json" = {
      force = true;
      text  = builtins.toJSON ({
      model = config.copilotCli.model;
      effortLevel = config.copilotCli.effortLevel;
      statusLine = {
        type = "command";
        command = "bash ${config.home.homeDirectory}/.copilot/statusline-command.sh";
      };
    } // optionalAttrs (config.copilotCli.allowedUrls != [ ]) {
      allowedUrls = config.copilotCli.allowedUrls;
    } // optionalAttrs (config.copilotCli.hooks != { }) {
      hooks = config.copilotCli.hooks;
    } // config.copilotCli.extraSettings);
    };
  };
}
