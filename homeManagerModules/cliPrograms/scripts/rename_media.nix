{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "rename_media" ''
      set -euo pipefail

      DIR="''${1:-.}"

      find "$DIR" -type d ! -path "$DIR" -exec bash -c '
        shopt -s nullglob
        i=1
        for f in "$1"/*.{jpg,JPG,jpeg,JPEG,png,PNG,mp4,MP4,mkv,MKV}; do
          [ -f "$f" ] || continue
          ext="''${f##*.}"
          ext="''${ext,,}"
          base="''${f##*/}"
          if [[ "$base" =~ ^[0-9]+\\.''${ext}$ ]]; then
            continue  # Skip already renamed files
          fi
          mv "$f" "$1/$((i++)).$ext"
        done
      ' bash {} \;
    '')
  ];
}
