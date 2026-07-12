{ config, lib, pkgs, ... }:

with lib;

{
  options.claudeCode.hooks = mkOption {
    type = types.attrs;
    default = { };
    description = "Extra `hooks` entries merged into ~/.claude/settings.json (host-specific, e.g. desktop notifications).";
  };

  config = {
    home.packages = [ pkgs.jq ];

    home.file.".claude/statusline-command.sh" = {
      source = ./claude-code-statusline.sh;
      executable = true;
    };

    home.file.".claude/settings.json".text = builtins.toJSON ({
      theme = "dark";
      editorMode = "vim";
      statusLine = {
        type = "command";
        command = "bash ${config.home.homeDirectory}/.claude/statusline-command.sh";
      };
    } // optionalAttrs (config.claudeCode.hooks != { }) {
      hooks = config.claudeCode.hooks;
    });
  };
}
