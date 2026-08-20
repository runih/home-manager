{ config, lib, pkgs, pkgsUnstable ? null, ... }:

with lib;

{
  options.opencode.baseURL = mkOption {
    type = types.str;
    default = "http://192.168.7.5:11434/v1";
    description = "Base URL (OpenAI-compatible, including /v1) of the Ollama endpoint OpenCode talks to.";
  };

  config = {
    programs.opencode = {
      enable = true;
      # opencode ships releases far faster than nixpkgs-26.05 backports them
      # (stable was 3 minor versions behind at time of writing) — pull from
      # nixpkgs-unstable instead, same as claude-code/github-copilot-cli.
      package = if pkgsUnstable != null then pkgsUnstable.opencode else pkgs.opencode;
      settings = {
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Home LAN Ollama";
          options.baseURL = config.opencode.baseURL;
          models = {
            "qwen2.5-coder:14b".name = "Qwen2.5 Coder 14B";
            "llama3.1:8b".name = "Llama 3.1 8B";
          };
        };
      };
    };
  };
}
