{
  pkgs,
  lib,
  user,
  ...
}: let
  pythonEnv = pkgs.python3.withPackages (p: [
    p.pillow
    p.materialyoucolor
    p.python-magic
  ]);
in {
  imports = [
    ./fuzzel.nix
    ./wlogout.nix
    ./kitty.nix
    ./quickshell
    ./scripts
  ];

  home.packages = with pkgs; [
    bc
    glib
    gsettings-desktop-schemas
    (pkgs.writeShellScriptBin "matugen" ''
      subcmd="$1"
      shift
      exec ${pkgs.matugen}/bin/matugen "$subcmd" --quiet "$@"
    '')
    libnotify
    file # libmagic for python-magic
    (pkgs.python3Packages.kde-material-you-colors.overridePythonAttrs (old: {
      pythonRuntimeDepsCheckHook = pkgs.writeShellScript "pythonRuntimeDepsCheckHook" "";
      propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [pkgs.python3Packages.python-magic];
    }))
    (pkgs.writeShellScriptBin "plasma-apply-colorscheme" ''
      exit 0
    '')
    adw-gtk3
    pywalfox-native
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.adw-gtk3}/share:$XDG_DATA_DIRS";
  };

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kvantum";
    style.name = lib.mkForce "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = lib.mkForce ''
    [General]
    theme=MaterialAdw
  '';

  xdg.configFile."matugen".source = ./matugen;
  xdg.configFile."Kvantum/Colloid".source = ./Kvantum/Colloid;

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

      # Copy Kvantum MaterialAdw to writable location so materialQT.sh can recolor it
      rm -rf "$HOME/.config/Kvantum/MaterialAdw"
      cp -r ${./Kvantum/MaterialAdw} "$HOME/.config/Kvantum/MaterialAdw"
      chmod -R u+w "$HOME/.config/Kvantum/MaterialAdw"
  '';

  home.activation.zellijWritableConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
    rm -f "$HOME/.config/zellij/config.kdl"
    cp --no-preserve=mode ${../cliPrograms/zellij/config.kdl} "$HOME/.config/zellij/config.kdl"
    ${pkgs.python3}/bin/python3 ${../rice/scripts/zellij-apply-colors.py} || true
  '';

  #TODO: add proper file...
  xdg.configFile."wallust/wallust.toml".text = ''
    backend = "kmeans"
    color_space = "salience"
    palette = "dark"

    [templates]
    colors_json = { template = 'colors.json', target = '~/.cache/wal/colors.json' }
  '';

  xdg.configFile."wallust/templates/colors.json".text = ''
    {
        "wallpaper": "{wallpaper}",
        "alpha": "{alpha}",

        "special": {
            "background": "{color0}",
            "foreground": "{color15}",
            "cursor": "{color15}"
        },
        "colors": {
            "color0": "{color0}",
            "color1": "{color1}",
            "color2": "{color2}",
            "color3": "{color3}",
            "color4": "{color4}",
            "color5": "{color5}",
            "color6": "{color6}",
            "color7": "{color7}",
            "color8": "{color8}",
            "color9": "{color9}",
            "color10": "{color10}",
            "color11": "{color11}",
            "color12": "{color12}",
            "color13": "{color13}",
            "color14": "{color14}",
            "color15": "{color15}"
        }
    }
  '';
}
