{pkgs, ...}: {
  imports = [
    ./common.nix
    ./windowManagers
  ];

  awesomeWM.enable = true;

  home.packages = with pkgs; [
    protonvpn-gui
  ];
}
