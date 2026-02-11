{
  lib,
  config,
  ...
}:
{
  options = {
    alacritty.enable = lib.mkEnableOption "enable alacritty terminal";
  };

  config = lib.mkIf config.alacritty.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        cursor = {
          blink_interval = 550;
          unfocused_hollow = false;

          style = {
            blinking = "On";
            shape = "Block";
          };
        };

        window = {
          decorations = "none";
          dynamic_title = true;
          # opacity = 0.95;
          opacity = 0.80;
          padding = {
            x = 12;
            y = 12;
          };
        };

        colors = {
            primary = {
                # background = "0x1d1f21";
                # foreground = "0xffffff";
            };
        };

        font = {
            size = 14.0;
        };
      };
    };
  };
}
