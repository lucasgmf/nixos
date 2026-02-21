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
    # empty uinput group
    users.groups.uinput = {};

    services.udev.extraRules = '' KERNEL=="uinput", GROUP="uinput", MODE="0660" '';

    programs.zsh.enable = true;
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
        "input"
        "uinput"
      ];
      openssh.authorizedKeys.keys = [];
      shell = pkgs.zsh;
      uid = user.uid;
    };

    nix.settings.trusted-users = ["${user.name}"];
  };
}
