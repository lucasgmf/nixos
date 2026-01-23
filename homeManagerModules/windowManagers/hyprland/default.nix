{ pkgs, lib, config, ... }: {
  
  imports = [
    ./hyprconf/keys.nix
  ];

  options.hyprlandConf = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
    };

    config = lib.mkIf config.hyprlandConf.enable {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
           exec-once = [
            "gnome-keyring-daemon --start --components=secrets,ssh"
            "swww-daemon"
            "nm-applet --indicator"
            "waybar"
            "dunst"
            "swww img /home/lucasgmf/Pictures/Dahyun/amimirr.jpg"
	    ];

           monitor = "eDPI-1,2880x1800@90,auto,2";

           input = {
             kb_layout = "pt";
             follow_mouse = 1;
             sensitivity = 0;
            
             touchpad.natural_scroll = false;
            };

        extraConfig = ''
          $terminal = kitty
          $fileManager = dolphin
          $menu = wofi --show drun

          # Multimedia keys
          "bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          "bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          "bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          "bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          "bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        '';
      };
      };
  };
}
