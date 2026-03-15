{
  config,
  lib,
  ...
}: {
  options = {
    zellij.enable = lib.mkEnableOption "enable zellij";
    zellij.zshIntegration = lib.mkEnableOption "enable zellij integration with Zsh";
  };

  config = lib.mkIf config.zellij.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = lib.mkDefault true;
    };

    # stylix.targets.zellij.enable = true;
    home.file =
      # let
      # colors = config.lib.stylix.colors.withHashtag;
      # in
      {
        ".config/zellij/config.kdl" = {
          text = ''
            ${builtins.readFile ./config.kdl}
          '';
          force = true;
        };

        ".config/zellij/layouts" = {
          source = ./layouts;
          recursive = true;
        };

        # ".config/zellij/plugins/zjframes.wasm" = {
        #   source = ./extraPlugins/zjframes.wasm;
        # };

        ".config/zellij/plugins/zjstatus.wasm" = {
          source = ./extraPlugins/zjstatus.wasm;
        };
      };
  };
}
