{
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    (pkgs.writeShellScriptBin "apply-colors" ''
      # 1. Zellij
      zellij-apply-colors || true
      zellij action reload-config 2>/dev/null || true

      # 2. Kvantum Qt theming
      sh ~/.config/quickshell/ii/scripts/kvantum/materialQT.sh || true
      ${pkgs.python3}/bin/python3 ~/.config/quickshell/ii/scripts/kvantum/changeAdwColors.py || true

      # 3. KDE Material You colors
      ${pkgs.python3.withPackages (p: [p.python-magic p.materialyoucolor])}/bin/python3 \
        -m kde_material_you_colors 2>/dev/null || true

      # 4. opencode theme
      opencode-apply-colors || true

      # 5. GTK — bounce the theme to force a reload
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "" 2>/dev/null || true
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark" 2>/dev/null || true

      # 6. Quickshell — touch the colors file to trigger live reload
      touch "''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/colors.json" 2>/dev/null || true

      # 6b. Terminal colors — generate sequences.txt from material_colors.scss and broadcast to all PTYs
      SCSS="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/material_colors.scss"
      SEQ_TEMPLATE="$HOME/.config/quickshell/ii/scripts/colors/terminal/sequences.txt"
      SEQ_OUT="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/terminal/sequences.txt"
      if [ -f "''$SCSS" ] && [ -f "''$SEQ_TEMPLATE" ]; then
        declare -A TERM_COLORS
        for i in $(seq 0 15); do
          val=$(sed -n "s/.*\\\$term''${i}: \(#[0-9a-fA-F]*\);.*/\1/p" "''$SCSS" | head -1)
          if [ -n "''$val" ]; then
            TERM_COLORS["term''${i}"]="''$val"
          fi
        done
        TERM0="''${TERM_COLORS[term0]:-}"
        TERM7="''${TERM_COLORS[term7]:-}"
        if [ -n "''$TERM0" ] && [ -n "''$TERM7" ]; then
          mkdir -p "$(dirname "''$SEQ_OUT")"
          SEQ_CONTENT=$(\cat "''$SEQ_TEMPLATE")
          for i in $(seq 15 -1 0); do
            val="''${TERM_COLORS[term''${i}]:-}"
            if [ -n "''$val" ]; then
              SEQ_CONTENT="''${SEQ_CONTENT//\$term''${i}/''${val#\#}}"
            fi
          done
          printf '%s' "''$SEQ_CONTENT" > "''$SEQ_OUT"
          for pty in /dev/pts/[0-9]*; do
            printf '%s' "''$SEQ_CONTENT" > "''$pty" 2>/dev/null || true
          done
        fi
      fi

      # 6c. Alacritty colors
      COLORS="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/colors.json"
      if [ -f "''$COLORS" ]; then
      mkdir -p "$HOME/.config/alacritty"
      ${pkgs.jq}/bin/jq -r '
          "[colors.primary]",
          "background = \"" + .background + "\"",
          "foreground = \"" + .on_background + "\"",
          "",
          "[colors.normal]",
          "black = \""   + .surface_container_lowest + "\"",
          "red = \""     + .error + "\"",
          "green = \""   + .tertiary_fixed_dim + "\"",
          "yellow = \""  + .on_tertiary_container + "\"",
          "blue = \""    + .primary_fixed_dim + "\"",
          "magenta = \"" + .secondary_fixed_dim + "\"",
          "cyan = \""    + .tertiary_fixed + "\"",
          "white = \""   + .on_surface_variant + "\"",
          "",
          "[colors.bright]",
          "black = \""   + .surface_container_highest + "\"",
          "red = \""     + .on_error_container + "\"",
          "green = \""   + .tertiary_fixed + "\"",
          "yellow = \""  + .on_tertiary_container + "\"",
          "blue = \""    + .primary_fixed + "\"",
          "magenta = \"" + .on_primary_container + "\"",
          "cyan = \""    + .secondary_fixed + "\"",
          "white = \""   + .on_background + "\""
      ' "''$COLORS" > "$HOME/.config/alacritty/colors.toml"
      fi

      # 7. Hyprland reload
      hyprctl reload 2>/dev/null || true

      # 8. Hyprland border colors
      COLORS="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/colors.json"
      if [ -f "''$COLORS" ]; then
        primary=$(${pkgs.jq}/bin/jq -r '.primary' "''$COLORS")
        tertiary=$(${pkgs.jq}/bin/jq -r '.tertiary' "''$COLORS")
        surface=$(${pkgs.jq}/bin/jq -r '.surface_container_highest' "''$COLORS")
        hyprctl keyword general:col.active_border "rgba(''${primary#\#}ff) rgba(''${tertiary#\#}ff) 45deg" 2>/dev/null || true
        hyprctl keyword general:col.inactive_border "rgba(''${surface#\#}ff)" 2>/dev/null || true
      fi
    '')
  ];
}
