{
  pkgs,
  lib,
  config,
  ...
}:

let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = config.customSDDM.astronautTheme;
  };
in
{

 options.customSDDM = {
  enable = lib.mkEnableOption "enables custom configuration of sddm";
  astronautTheme = lib.mkOption {
    type = lib.types.str;
    default = "hyprland_kath";
    description = "Astronaut SDDM embedded theme";
  };
};

  config = lib.mkIf config.customSDDM.enable {
    services.displayManager.sddm = {
      enable = true;
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
