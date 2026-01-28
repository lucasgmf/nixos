{
  lib,
  user,
  ...
}: {
  imports = [
    # desktop environments / window managers
    ./windowManagers/hyprland.nix
    ./loginManager

    # other modules
    ./system
    # ./stylix

    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "${user.name}"])
  ];
  hyprland.enable = true;
  customSDDM = {
	  enable = true;
	  astronautTheme = "pixel_sakura_static";
  };
}
