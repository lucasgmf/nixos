{
  pkgs,
  lib,
  config,
  ...
}:
let
  sakura = "${pkgs.base16-schemes}/share/themes/sakura.yaml";
in
{
  options = {
    autoStyling = {
      enable = lib.mkEnableOption "enables stylix auto styling";
      colorScheme = lib.mkOption { default = sakura; };
      image = lib.mkOption { default = ./default.png; };
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
