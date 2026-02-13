{ pkgs, lib, config, ... }: {

    imports = [
        ./hyprconf/keys.nix
        ./hyprconf/xcompose.nix
        ./hyprconf/darktheme.nix
    ];

    options.hyprlandConf = {
        enable = lib.mkEnableOption "Hyprland desktop environment";
    };

    config = lib.mkIf config.hyprlandConf.enable {

        darkTheme.enable = true;

        home.packages = [
            (pkgs.writeShellScriptBin "switch_workspace" (builtins.readFile ./scripts/switch_workspace.sh))
            (pkgs.writeShellScriptBin "reset_background" (builtins.readFile ./scripts/reset_background.sh))
        ];

        wayland.windowManager.hyprland = {
            enable = true;
            settings = {
                "$mainMod" = "SUPER";
                "$terminal" = "alacritty";
                "$fileManager" = "nautilus";
                "$menu" = "wofi --show drun";

                exec-once = [
                    "hyprctl setcursor rose-pine-hyprcursor 32"
                        "gnome-keyring-daemon --start --components=secrets,ssh"
                        "swww-daemon"
                        "nm-applet --indicator"
                        "waybar"
                        "dunst"
                        "swww img /home/lucasgmf/Pictures/background2.jpg"
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
                    '';
            };
        };
    };
                            }
