{ pkgs, lib, config, ... }: {
  
  imports = [
    # ./hyprconf/keys.nix
  ];

  options.hyprlandConf = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
    };

    config = lib.mkIf config.hyprlandConf.enable {
      wayland.windowManager.hyprland = {
        enable = true;
      };
  };
}
