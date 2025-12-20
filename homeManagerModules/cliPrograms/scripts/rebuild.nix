{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "rebuild" ''
      set -e
      pushd ~/nixos/
      git add .
      git diff -U0 *.nix
      echo "NixOS Rebuilding..."
      nh os switch .
      current=$(readlink /nix/var/nix/profiles/system | cut -d- -f2)
      git commit -am "Generation $current"
      popd
    '')
  ];
}
