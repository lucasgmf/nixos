{
  lib,
  user,
  ...
}: {
  imports = [
    # desktop environments / window managers
    ./awesome
    ./gnome

    # other modules
    ./gaming
    ./system
    ./stylix
    ./rules
    ./nvidia

    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" "${user.name}"])
  ];
}
