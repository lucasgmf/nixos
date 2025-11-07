{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      set -e  # Exit on error
      
      reset_flake() {
        echo "Error occurred, resetting flake..."
        cd ~/nixos/
        git reset --hard
      }
      trap reset_flake ERR
      
      echo "NixOS Updating..."
      cd ~/nixos/
      nh os switch --update --ask
      
      gen=$(nixos-rebuild list-generations | grep current)
      git commit -am "$gen"
    '')
  ];
}
