{
  config,
  lib,
  ...
}: {
  programs.opencode.settings = {
    # "$schema" = "https://opencode.ai/config.json";

    model = "ollama/gpt-oss:20b-64k"; # default model for opencode

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

    # theme = "material-you";

    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (Windows)";
        options = {
          baseURL = "http://192.168.1.88:11434/v1";
        };
        models = {
          "gpt-oss:20b-64k" = {
            name = "GPT-OSS 20B (64k)";
            # tools = true;
          };
          "qwen3-coder:30b-64k" = {
            name = "Qwen3-Coder 30B (64k)";
            # tools = true;
          };
        };
      };
    };
  };
}
