{
  pkgs,
  lib,
  config,
  user,
  ...
}: {
  options = {
    user.enable = lib.mkEnableOption "enables default user (lucasgmf) as a trusted user";
  };

  config = lib.mkIf config.user.enable {
    users.users.${user.name} = {
      isNormalUser = true;
      description = user.description;
      extraGroups = [
        "networkmanager"
        "wheel"
        "gamemode"
        "docker"
        "plugdev"
        "wireshark"
        "dialout"
        "uucp"
      ];
      openssh.authorizedKeys.keys = [];
      shell = pkgs.nushell;
      uid = user.uid;
    };

    nix.settings.trusted-users = ["${user.name}"];
  };
}
