{
  lib,
  user,
  ...
}: {
  imports = [
    # desktop environments / window managers
    ./windowManagers/gnome
    ./windowManagers/hyprland.nix

    # other modules
    ./system
    # ./stylix

    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "${user.name}"])
  ];
}
