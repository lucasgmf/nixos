{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.autoStyling.enable {
    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans # Korean + CJK
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.fira-mono
      # extras:
      nerd-fonts.jetbrains-mono
      font-awesome
    ];

    stylix.fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-mono;
        name = "FiraMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts-cjk-sans;
        name = "Noto Sans CJK KR";
      };
      serif = {
        package = pkgs.noto-fonts-cjk-serif;
        name = "Noto Serif CJK KR";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      # Uncomment if you want custom sizes
      # sizes = {
      #   applications = 11;
      #   terminal = 12;
      #   desktop = 10;
      #   popups = 11;
      # };
    };

    fonts.fontconfig.enable = true;
  };
}
