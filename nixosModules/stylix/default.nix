{
  pkgs,
  lib,
  config,
  ...
}:
let
  # colorSchemeLink = "${pkgs.base16-schemes}/share/themes/tokyo-city-terminal-dark.yaml";
  # colorSchemeLink = "${pkgs.base16-schemes}/share/themes/horizon-dark.yaml";
  # colorSchemeLink = "${pkgs.base16-schemes}/share/themes/horizon-light.yaml";
  colorSchemeLink = ./mytheme.yaml;
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
      enable = true;
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
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
