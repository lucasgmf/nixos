{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./settings.nix
    ./rules.nix
  ];

  programs.opencode.enable = true;

  programs.opencode.package = pkgs.opencode;
}
