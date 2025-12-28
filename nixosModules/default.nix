{
  lib,
  user,
  ...
}: {
  imports = [
    # desktop environments / window managers
    ./gnome
    ./hyprland

    # other modules
    ./system
    ./stylix

    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "${user.name}"])
  ];
}
