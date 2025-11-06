{
  lib,
  user,
  ...
}: {
  imports = [
    # desktop environments / window managers
    ./gnome

    # other modules
    ./system
    ./stylix

    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "${user.name}"])
  ];
}
