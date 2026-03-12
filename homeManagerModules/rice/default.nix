{
  pkgs,
  lib,
  user,
  ...
}: let
  pythonEnv = pkgs.python3.withPackages (p: [
    p.pillow
    p.materialyoucolor
  ]);
in {
  imports = [
    ./fuzzel.nix
    ./wlogout.nix
    ./kitty.nix
    ./quickshell
  ];

  home.packages = with pkgs; [
    bc
    glib
    gsettings-desktop-schemas
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS";
  };

  xdg.configFile."matugen".source = ./matugen;

  wayland.windowManager.hyprland.settings = {
    env = [
      "ILLOGICAL_IMPULSE_VIRTUAL_ENV,~/.local/state/quickshell/.venv"
    ];
  };

  home.activation.createQuickshellVenv = lib.hm.dag.entryAfter ["writeBoundary"] ''
      VENV_DIR="$HOME/.local/state/quickshell/.venv"
      mkdir -p "$VENV_DIR/bin"
      cat > "$VENV_DIR/bin/activate" << 'EOF'
    export PATH="${pythonEnv}/bin:$PATH"
    deactivate() { :; }
    EOF
      ln -sf ${pythonEnv}/bin/python3 "$VENV_DIR/bin/python3"
      ln -sf ${pythonEnv}/bin/python3 "$VENV_DIR/bin/python"

      mkdir -p "$HOME/.local/state/quickshell/user/generated/terminal"
      chmod 644 "$HOME/.local/state/quickshell/user/generated/terminal/sequences.txt" 2>/dev/null || true
      mkdir -p "$HOME/.config/hypr/custom/scripts"
  '';
}
