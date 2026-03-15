{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./apply-colors.nix
    ./opencode-apply-colors.nix
  ];

  home.packages = [
    (pkgs.writeShellScriptBin "zellij-apply-colors" ''
      exec ${pkgs.python3}/bin/python3 ${./zellij-apply-colors.py}
    '')
  ];
}
