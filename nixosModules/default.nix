{
  lib,
  user,
  ...
}:
{
  imports = [
    ./windowManagers/hyprland.nix
    ./loginManager
    ./system
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "${user.name}" ])
  ];
  hyprland.enable = true;
  customSDDM = {
    enable = true;
    astronautTheme = "pixel_sakura_static";
  };
}
