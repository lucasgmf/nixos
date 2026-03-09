{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.matugen.packages.${pkgs.system}.default
  ];

  # Main fuzzel - includes the theme file matugen generates
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    include="~/.config/fuzzel/fuzzel_theme.ini"
    font=JetBrainsMono Nerd Font:weight=medium
    terminal=kitty -1
    prompt=">>  "
    layer=overlay

    [border]
    radius=17
    width=1

    [dmenu]
    exit-immediately-if-empty=yes
  '';

  # Matugen config — defines all templates matugen will generate
  xdg.configFile."matugen/config.toml".text = ''
    [config]
    version_check = false

    [templates.fuzzel]
    input_path  = '~/.config/matugen/templates/fuzzel/fuzzel_theme.ini'
    output_path = '~/.config/fuzzel/fuzzel_theme.ini'
  '';

  # The template matugen uses to generate fuzzel's colors from your wallpaper
  xdg.configFile."matugen/templates/fuzzel/fuzzel_theme.ini".text = ''
    [colors]
    background={{colors.background.default.hex_stripped}}ff
    text={{colors.on_background.default.hex_stripped}}ff
    selection={{colors.surface_variant.default.hex_stripped}}ff
    selection-text={{colors.on_surface_variant.default.hex_stripped}}ff
    border={{colors.surface_variant.default.hex_stripped}}dd
    match={{colors.primary.default.hex_stripped}}ff
    selection-match={{colors.primary.default.hex_stripped}}ff
  '';
}
