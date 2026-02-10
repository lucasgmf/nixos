{
  pkgs,
  lib,
  config,
  ...
}:
let
  colorSchemeLink = ./default.yaml;
in
{
  imports = [
    ./fonts.nix
  ];

  options = {
    autoStyling = {
      enable = lib.mkEnableOption "enables stylix auto styling";
      colorScheme = lib.mkOption {
        default = colorSchemeLink;
        description = "Base16 color scheme for Stylix";
      };
      useDynamicColors = lib.mkEnableOption "use pywal for dynamic runtime theming";
    };
  };

  config = lib.mkIf config.autoStyling.enable {
    stylix = {
      enable = true;
      base16Scheme = config.autoStyling.colorScheme;

      # Don't manage wallpaper - let Hyprland handle it
      image = lib.mkForce null;

      # Disable Stylix theming for apps you want pywal to handle
      targets = lib.mkIf config.autoStyling.useDynamicColors {
        # TODO: add more apps here
        hyprland.enable = false;
        # BUG: Breaks waybar
        # waybar.enable = false;
        kitty.enable = false;
        alacritty.enable = false;
        rofi.enable = false;
      };
    };
  };
}
