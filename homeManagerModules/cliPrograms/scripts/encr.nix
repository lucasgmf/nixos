{ pkgs, ... }:

{
  # Define the package to automate the mounting/unmounting process
  home.packages = [
    (pkgs.writeShellScriptBin "encfs-toggle" ''
      set -e

      # Ensure encfs is available in the environment
      nix-shell -p encfs --run '

        # Define the EncFS directories
        ENCFS_DIR=~/Documents/.encr_uwu
        MOUNT_POINT=~/Documents/uwu

        # Check if the mount point is already mounted
        if mountpoint -q "$MOUNT_POINT"; then
          echo "Unmounting EncFS..."
          fusermount -u "$MOUNT_POINT"
          echo "Files are now hidden."
        else
          echo "Mounting EncFS..."
          encfs "$ENCFS_DIR" "$MOUNT_POINT"
          echo "Files are now accessible."
        fi
      '
    '')
  ];
}

