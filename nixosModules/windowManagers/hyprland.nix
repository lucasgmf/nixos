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
      portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
      xwayland.enable = true; # enable x applications within wayland compositor
    };

    # Critical: Enable proper session management
    security.polkit.enable = true;

    services.gnome.gnome-keyring.enable = true;

    # Ensure proper session environment setup
    services.displayManager.sessionPackages = [
      inputs.hyprland.packages."${pkgs.system}".hyprland
    ];

    hardware.graphics.enable = true;

    environment.sessionVariables = {
      QML2_IMPORT_PATH = [
        "${pkgs.qt6.qt5compat}/lib/qt-6/qml"
        "${pkgs.kdePackages.kirigami}/lib/qt-6/qml"
        "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
        "${pkgs.kdePackages.qtpositioning}/lib/qt-6/qml"
      ];
    };

    environment.systemPackages = with pkgs; [
      # enables workspaces displayed correctly? test without it!
      (
        pkgs.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        })
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
      #TODO: Remove it
      wofi

      fuzzel
    ];
  };
}
