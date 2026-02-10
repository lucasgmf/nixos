{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.darkTheme;
in
{
  options.darkTheme = {
    enable = lib.mkEnableOption "enable dark GTK / QT theme";
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = {
        name = lib.mkForce "adw-gtk3-dark";
        package = lib.mkForce pkgs.adw-gtk3;
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = lib.mkForce "gtk";
      style.name = lib.mkForce "adwaita-dark";
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.mkForce "prefer-dark";
      };
    };

    home.packages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];

    xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = ''
      [preferred]
      default=gtk
      org.freedesktop.impl.portal.Settings=gtk
    '';
  };
}
