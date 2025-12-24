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
      
      # Get generation info from the system profile
      gen_number=$(ls -v /nix/var/nix/profiles/system-*-link 2>/dev/null | tail -1 | grep -oP 'system-\K\d+')
      gen_date=$(date '+%Y-%m-%d %H:%M:%S')
      nixos_version=$(nixos-version)
      kernel_version=$(uname -r)
      
      git commit -m "$gen_number current  $gen_date  $nixos_version  $kernel_version"
      popd
    '')
  ];
}
