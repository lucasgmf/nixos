{
  pkgs,
  lib,
  config,
  ...
}: let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
    #themeConfig = {
    #  Background = "path/to/background.jpg";
    #  Font = "M+1 Nerd Font";
    #};
  };
in {
  options = {
    customSDDM.enable = lib.mkEnableOption "enables custom configuration of sddm";
  };
  
  config = lib.mkIf config.customSDDM.enable {
    services.displayManager.sddm = {
      enable = true;
      # experimental support
      wayland.enable = true;
      
      extraPackages = with pkgs; [
        custom-sddm-astronaut
      ];
      
      theme = "sddm-astronaut-theme";
      
      settings = {
        Theme = {
          Current = "sddm-astronaut-theme";
        };
      };
    };
    
    environment.systemPackages = with pkgs; [
      custom-sddm-astronaut
      kdePackages.qtmultimedia
    ];
  };
}
