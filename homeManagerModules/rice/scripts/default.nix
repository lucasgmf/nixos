{
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    (pkgs.writeShellScriptBin "zellij-apply-colors" ''
      exec ${pkgs.python3}/bin/python3 ${./zellij-apply-colors.py}
    '')
    (pkgs.writeShellScriptBin "opencode-apply-colors" ''
      exec ${pkgs.bash}/bin/bash ${./opencode-apply-colors.sh}
    '')
  ];
}
