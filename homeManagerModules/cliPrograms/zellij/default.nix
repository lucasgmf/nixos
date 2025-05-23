{
  config,
  lib,
  ...
}:
{
  options = {
    zellij.enable = lib.mkEnableOption "enable zellij";
    zellij.zshIntegration = lib.mkEnableOption "enable zellij integration with Zsh";
  };

  config = lib.mkIf config.zellij.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = lib.mkDefault true;
    };

    stylix.targets.zellij.enable = true;
    home.file =
      let
        colors = config.lib.stylix.colors.withHashtag;
      in
      {
        ".config/zellij/config.kdl".text = ''
          ${builtins.readFile ./config.kdl}

          theme "stylix"
          themes {
            stylix {
              bg "${colors.base03}"
              fg "${colors.base05}"

              red "${colors.base08}"
              green "${colors.base0B}"
              blue "${colors.base0D}"

              yellow "${colors.base0A}"
              magenta "${colors.base0E}"
              orange "${colors.base09}"
              cyan "${colors.base0C}"

              black "${colors.base00}"
              white "${colors.base07}"
            }
          }
        '';

        ".config/zellij/layouts" = {
          source = ./layouts;
          recursive = true;
        };
      };
  };
}
