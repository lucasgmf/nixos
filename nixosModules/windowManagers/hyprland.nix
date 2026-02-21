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
      #package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
      xwayland.enable = true; # enable x applications within wayland compositor
    };

    # Critical: Enable proper session management
    security.polkit.enable = true;

    services.gnome.gnome-keyring.enable = true;
  
    # Ensure proper session environment setup
    services.displayManager.sessionPackages = [ pkgs.hyprland ];

    hardware.graphics.enable = true;

    environment.systemPackages = with pkgs; [

    # enables workspaces displayed correctly? test without it!
    (pkgs.waybar.overrideAttrs (oldAttrs: {
	mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];})
    )

      # terminal
      kitty

      # control brightness
      brightnessctl

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

