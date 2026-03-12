{
  pkgs,
  lib,
  user,
  ...
}: let
  pythonEnv = pkgs.python3.withPackages (p: [
    p.pillow
    p.materialyoucolor
  ]);
in {
  imports = [
    ./fuzzel.nix
    ./wlogout.nix
    ./kitty.nix
    ./quickshell
  ];

  home.packages = with pkgs; [
    bc
    glib
    gsettings-desktop-schemas
  ];

  wayland.windowManager.hyprland.settings = {
    env = [
      "ILLOGICAL_IMPULSE_VIRTUAL_ENV,${pythonEnv}"
    ];
  };
}
