#!/usr/bin/env bash
COLORS="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/generated/colors.json"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json"

primary=$(jq -r '.primary' "$COLORS")
secondary=$(jq -r '.secondary' "$COLORS")
tertiary=$(jq -r '.tertiary' "$COLORS")
background=$(jq -r '.background' "$COLORS")
surface_container=$(jq -r '.surface_container' "$COLORS")
surface_container_high=$(jq -r '.surface_container_high' "$COLORS")
outline_variant=$(jq -r '.outline_variant' "$COLORS")
on_background=$(jq -r '.on_background' "$COLORS")
on_surface_variant=$(jq -r '.on_surface_variant' "$COLORS")
outline=$(jq -r '.outline' "$COLORS")

jq --arg p "$primary" \
    --arg s "$secondary" \
    --arg a "$tertiary" \
    --arg bg "$background" \
    --arg bgp "$surface_container" \
    --arg bge "$surface_container_high" \
    --arg b "$outline_variant" \
    --arg t "$on_background" \
    --arg ts "$on_surface_variant" \
    --arg tm "$outline" \
    '.theme = {
     primary: $p,
     secondary: $s,
     accent: $a,
     background: $bg,
     backgroundPanel: $bgp,
     backgroundElement: $bge,
     border: $b,
     text: $t,
     textSecondary: $ts,
     textMuted: $tm
   }' "$CONFIG" >/tmp/opencode_tmp.json && mv /tmp/opencode_tmp.json "$CONFIG"
