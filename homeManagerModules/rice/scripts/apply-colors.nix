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

      # 7. Hyprland reload
      hyprctl reload 2>/dev/null || true
    '')
  ];
}
