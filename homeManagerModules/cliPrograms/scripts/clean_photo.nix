{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "clean_photo_metadata" ''
      set -e

      nix-shell -p exiftool --run '
        TARGET_DIR="$1"

        # Use current directory if none is given
        if [ -z "$TARGET_DIR" ]; then
          TARGET_DIR="."
        fi

        echo "Removing metadata from images in: $TARGET_DIR"
        find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec exiftool -overwrite_original -all= {} +
        echo "Metadata removal complete."
      '
    '')
  ];
}
