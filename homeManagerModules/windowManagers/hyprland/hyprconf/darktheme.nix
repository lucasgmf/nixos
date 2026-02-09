{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    darkTheme.enable = lib.mkEnableOption "enable darkTheme";
  };

  config = lib.mkIf config.darkTheme.enable {
      gtk = {
          enable = true;
          theme = {
              name = "Adwaita-dark";
              package = pkgs.gnome-themes-extra;
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
            platformTheme.name = "gtk";
            style.name = "adwaita-dark";
        };

        dconf.settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
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

