{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    customSDDM.enable = lib.mkEnableOption "enables custom configuration of sddm";
  };

  config = lib.mkIf config.customSDDM.enable {

  # enable major tooklits
  gtk.enable = true;
  qt.enable = true;
  };
}
