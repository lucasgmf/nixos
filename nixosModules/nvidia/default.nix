{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    nvidiaDrivers.enable = lib.mkEnableOption "Enable Nvidia drivers";
  };

  config = lib.mkIf config.nvidiaDrivers.enable {
    # Enable OpenGL
    hardware.graphics = {
      enable = true;
    };

    # Load Nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Prime offload settings
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # Make sure to use the correct Bus ID values for your system!
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management options
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Use the Nvidia open-source kernel module
      open = true;

      # Enable the Nvidia settings menu
      nvidiaSettings = true;

      # Select the appropriate Nvidia driver package
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
