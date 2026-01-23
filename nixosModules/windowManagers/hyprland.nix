{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options = {
    hyprland.enable = lib.mkEnableOption "enable hyprland window manager";
  };

  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      xwayland.enable = true; # enable x applications within wayland compositor

    };
    services.xserver.displayManager.lightdm.enable = true;
    hardware.graphics.enable = true;

    environment.systemPackages = with pkgs; [


    # enables workspaces displayed correctly? test without it!
    (pkgs.waybar.overrideAttrs (oldAttrs: {
	mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];})
    )

      # terminal
      kitty

      # simple waybar
      waybar

      # customizable waybar
      # eww

      # notifications
      dunst
      # notifications dependency 
      libnotify

      # wallpapers
      # hyprpaper
      # swaybg
      # wpaperd
      # mpvpaper
      swww

      #app launcher
      rofi

      #gtk rofi
      wofi

      #hyprland suggests...
      bemenu
      fuzzel
      tofi
    ];
  };
}

