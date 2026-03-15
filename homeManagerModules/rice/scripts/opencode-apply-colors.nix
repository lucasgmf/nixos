{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "opencode-apply-colors" ''
      COLORS="''${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/colors.json"
      THEME_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes"
      mkdir -p "$THEME_DIR"

      ${pkgs.jq}/bin/jq -n \
        --arg primary    "$(${pkgs.jq}/bin/jq -r '.primary'                "$COLORS")" \
        --arg secondary  "$(${pkgs.jq}/bin/jq -r '.secondary'              "$COLORS")" \
        --arg accent     "$(${pkgs.jq}/bin/jq -r '.tertiary'               "$COLORS")" \
        --arg error      "$(${pkgs.jq}/bin/jq -r '.error'                  "$COLORS")" \
        --arg text       "$(${pkgs.jq}/bin/jq -r '.on_background'          "$COLORS")" \
        --arg textMuted  "$(${pkgs.jq}/bin/jq -r '.on_surface_variant'     "$COLORS")" \
        --arg bg         "$(${pkgs.jq}/bin/jq -r '.background'             "$COLORS")" \
        --arg bgPanel    "$(${pkgs.jq}/bin/jq -r '.surface_container'      "$COLORS")" \
        --arg bgElem     "$(${pkgs.jq}/bin/jq -r '.surface_container_high' "$COLORS")" \
        --arg border     "$(${pkgs.jq}/bin/jq -r '.outline_variant'        "$COLORS")" \
        '{
          "$schema": "https://opencode.ai/theme.json",
          "theme": {
            "primary":           {"dark": $primary,   "light": $primary},
            "secondary":         {"dark": $secondary, "light": $secondary},
            "accent":            {"dark": $accent,    "light": $accent},
            "error":             {"dark": $error,     "light": $error},
            "text":              {"dark": $text,      "light": $text},
            "textMuted":         {"dark": $textMuted, "light": $textMuted},
            "background":        {"dark": $bg,        "light": $bg},
            "backgroundPanel":   {"dark": $bgPanel,   "light": $bgPanel},
            "backgroundElement": {"dark": $bgElem,    "light": $bgElem},
            "border":            {"dark": $border,    "light": $border}
          }
        }' > "$THEME_DIR/material-you.json"
    '')
  ];
}
