{
  pkgs,
  lib,
  config,
  ...
}: let
  colorSchemeLink = ./default.yaml;
in {
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
      image = lib.mkForce null;
      # Disable all app theming — only use stylix for fonts
      targets = {
        qt.enable = false;
        hyprland.enable = false;
        kitty.enable = false;
        alacritty.enable = false;
        rofi.enable = false;
        zellij.enable = false;
        gtk.enable = false;
        firefox.enable = false;
        opencode.enable = false;
      };
    };
  };
}
