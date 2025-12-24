{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "rebuild" ''
      set -e
      pushd ~/nixos/
      nvim
      git add .
      git diff --cached -U0 *.nix
      echo "NixOS Rebuilding..."
      nh os switch --ask
      git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
      popd
    '')
  ];
}
