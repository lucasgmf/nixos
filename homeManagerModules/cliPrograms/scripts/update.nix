{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      set -euo pipefail
      
      cd ~/nixos/
      
      echo "NixOS Updating..."
      if nh os switch --update --ask; then
        gen=$(nixos-rebuild list-generations | grep current)
        git commit -am "$gen" || echo "Nothing to commit"
      else
        echo "Update failed, resetting flake..."
        git reset --hard
        exit 1
      fi
    '')
  ];
}
