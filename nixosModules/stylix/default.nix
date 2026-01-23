{
  pkgs,
  lib,
  config,
  ...
}:
let
  colorSchemeLink = ./darkdahyun.yaml;
in
{
  options = {
    autoStyling = {
      enable = lib.mkEnableOption "enables stylix auto styling";
      colorScheme = lib.mkOption { default = colorSchemeLink; };
      image = lib.mkOption { default = ./default.jpg; };
    };
  };

  config = lib.mkIf config.autoStyling.enable {
    stylix = {
      enable = false;
      base16Scheme = config.autoStyling.colorScheme;
      image = config.autoStyling.image;

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.fira-mono;
          name = "FiraMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
