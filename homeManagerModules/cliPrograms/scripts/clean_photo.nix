{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "clean_photo_metadata" ''
      set -e

      # Ensure exiftool is available via nix-shell
      nix-shell -p exiftool --run '
        TARGET_DIR="$1"

        if [ -z "$TARGET_DIR" ]; then
          echo "Usage: clean_photo_metadata <directory>"
          exit 1
        fi

        echo "Removing metadata from images in: $TARGET_DIR"
        find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec exiftool -overwrite_original -all= {} +
        echo "Metadata removal complete."
      '
    '')
  ];
}
