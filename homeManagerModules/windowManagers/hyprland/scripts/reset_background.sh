#!/usr/bin/env bash

BG="$HOME/Pictures/background2.jpg"

hyprctl keyword decoration:active_opacity 1 > /dev/null
hyprctl keyword decoration:inactive_opacity 1 > /dev/null

swww img "$BG" \
  --resize crop \
  --transition-type none > /dev/null

