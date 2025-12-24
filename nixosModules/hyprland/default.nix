{lib, ...}: {
  imports = [
    ./hyprlandDE.nix
    # ./customControls.nix
    # ./config.nix
    # ./plugins.nix
  ];

  # the following is set in hosts/nix-laptop/default.nix
  # hyprlandDE.enable = lib.mkDefault true;
  # customcontrols.enable = lib.mkDefault true;
}
