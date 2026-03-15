{
  config,
  lib,
  ...
}: {
  programs.opencode.settings = {
    "$schema" = "https://opencode.ai/config.json";

    model = "ollama/qwen3:8b-64k";

    autoupdate = false;

    permission = {
      bash = {
        "*" = "ask";
        "cat *" = "allow";
        "git *" = "allow";
        "grep *" = "allow";
        "ls *" = "allow";
        "rm -rf *" = "deny";
        "sudo *" = "ask";
      };
      edit = "ask";
      read = "allow";
      webfetch = "ask";
    };

    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (Windows)";
        options = {
          baseURL = "http://192.168.1.105:11434/v1";
        };
        models = {
          "qwen3:8b-64k" = {
            name = "Qwen3 8B (64k)";
            tools = true;
          };
          "hermes3:8b-64k" = {
            name = "Hermes3 8B (64k)";
            tools = true;
          };
        };
      };
    };
  };
}
