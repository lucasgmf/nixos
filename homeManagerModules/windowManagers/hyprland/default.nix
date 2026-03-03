{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  background_path = /home/lucasgmf/Pictures/background2.jpg;
in {
  imports = [
    ./hyprconf/keys.nix
    ./hyprconf/xcompose.nix
    # broken?
    ./hyprconf/darktheme.nix
  ];

  options.hyprlandConf = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf config.hyprlandConf.enable {
    # darkTheme.enable = true;

    home.packages = [
      (pkgs.writeShellScriptBin "switch_workspace" (builtins.readFile ./scripts/switch_workspace.sh))
      (pkgs.writeShellScriptBin "reset_background" (builtins.readFile ./scripts/reset_background.sh))
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "alacritty";
        "$fileManager" = "nautilus";
        "$menu" = "wofi --show drun";

        misc = {
          disable_hyprland_logo = true;
        };

        exec-once = [
          "swww-daemon"
          "swww img ${toString background_path} -- resize crop -- transition-type none --transition-duration 0"
          "hyprctl setcursor rose-pine-hyprcursor 32"
          "gnome-keyring-daemon --start --components=secrets,ssh"
          "nm-applet --indicator"
          "waybar"
          "dunst"
          # "sleep 10 && aw-qt" # waybar is starting, tray is not ready yet
        ];

        monitor = "eDPI-1,2880x1800@90,auto,2";

        input = {
          kb_layout = "pt";
          follow_mouse = 1;
          sensitivity = 0;

          touchpad.natural_scroll = false;
        };
      };
    };
  };
}
