#!/usr/bin/env bash
COLORS="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/colors.json"
THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes"
mkdir -p "$THEME_DIR"

jq -n \
    --arg primary "$(jq -r '.primary' "$COLORS")" \
    --arg secondary "$(jq -r '.secondary' "$COLORS")" \
    --arg accent "$(jq -r '.tertiary' "$COLORS")" \
    --arg error "$(jq -r '.error' "$COLORS")" \
    --arg text "$(jq -r '.on_background' "$COLORS")" \
    --arg textMuted "$(jq -r '.on_surface_variant' "$COLORS")" \
    --arg bg "$(jq -r '.background' "$COLORS")" \
    --arg bgPanel "$(jq -r '.surface_container' "$COLORS")" \
    --arg bgElem "$(jq -r '.surface_container_high' "$COLORS")" \
    --arg border "$(jq -r '.outline_variant' "$COLORS")" \
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
  }' >"$THEME_DIR/material-you.json"
