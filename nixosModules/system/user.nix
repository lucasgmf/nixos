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
