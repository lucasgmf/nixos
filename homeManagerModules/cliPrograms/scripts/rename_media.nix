{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "rename_media" ''
      set -euo pipefail

      DIR="''${1:-.}"

      find "$DIR" -type d ! -path "$DIR" -exec bash -c '
        shopt -s nullglob
        i=1
        for f in "$1"/*.{jpg,JPG,jpeg,JPEG,png,PNG,mp4,MP4,mkv,MKV,mov,MOV}; do
          [ -f "$f" ] || continue
          ext="''${f##*.}"
          ext="''${ext,,}"
          base="''${f##*/}"
          # Use a full regex with escaping to skip files like 123.jpg or 45.MP4
          if [[ "$base" =~ ^[0-9]+\.(jpg|jpeg|png|mp4|mkv|mov)$ ]]; then
            continue
          fi
          mv "$f" "$1/$((i++)).$ext"
        done
      ' bash {} \;
    '')
  ];
}
