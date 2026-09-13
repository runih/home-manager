# Claude Code / GitHub Copilot CLI settings, split out of flake.nix's
# module list to keep that file to inputs/outputs plumbing.
{
  copilotCli.allowedUrls = [
    "http://localhost:8080"
    "http://localhost:7000"
    "http://172.16.4.10:8080"
    "http://192.168.7.37:8080"
    "http://192.168.7.37:7000"
    "https://gitlab.com"
  ];

  claudeCode.hooks = {
    Stop = [
      {
        hooks = [
          { type = "command"; command = ''hyprctl notify -1 2000 'rgb(7aa2f7)' 'Claude is done' 2>/dev/null || true''; }
        ];
      }
    ];
    Notification = [
      {
        hooks = [
          { type = "command"; command = ''hyprctl notify -1 2000 'rgb(7aa2f7)' 'Claude is waiting for input' 2>/dev/null || true''; }
        ];
      }
    ];
    PostToolUse = [
      {
        matcher = "Bash";
        hooks = [
          { type = "command"; command = ''cmd=$(jq -r '.tool_input.command'); [[ "$cmd" == "hm"* ]] && hyprctl notify -1 2000 'rgb(7aa2f7)' 'Configuration reloaded' 2>/dev/null || true''; }
        ];
      }
    ];
  };
}
