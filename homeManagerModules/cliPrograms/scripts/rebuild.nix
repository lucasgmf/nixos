{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "rebuild" ''
      set -e
      pushd ~/nixos/
      # nvim
      cd nixosSecrets/
      git add .
      git commit -m "$gen current  $(date '+%Y-%m-%d %H:%M:%S')  $(nixos-version)  $(uname -r)"
      cd ..
      nix flake update secrets
      git add .
      git diff --cached -U0 *.nix
      echo "NixOS Rebuilding..."
      nh os switch --ask
      gen=$(readlink /nix/var/nix/profiles/system | grep -oP 'system-\K\d+')
      git commit -m "$gen current  $(date '+%Y-%m-%d %H:%M:%S')  $(nixos-version)  $(uname -r)"
      popd
    '')
  ];
}
