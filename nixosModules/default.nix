{
  lib,
  user,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./windowManagers/hyprland.nix
    ./loginManager
    ./system
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "${user.name}"])
  ];
  nixpkgs.overlays = [
    (final: prev: {
      hyprland = inputs.hyprland.packages.${prev.system}.hyprland;
      xdg-desktop-portal-hyprland = inputs.hyprland.packages.${prev.system}.xdg-desktop-portal-hyprland;
    })
  ];
  hyprland.enable = true;
  customSDDM = {
    enable = true;
    astronautTheme = "pixel_sakura_static";
  };
}
