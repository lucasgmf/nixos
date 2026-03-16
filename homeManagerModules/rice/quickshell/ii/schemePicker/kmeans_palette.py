#!/usr/bin/env python3
"""
K-means palette generator for scheme-picker.
Extracts dominant colors from an image and builds light/dark variants,
outputting JSON in the same format as `matugen --json hex`.

Usage:
    kmeans_palette <image_path> --mode dark|light --clusters 8
"""

import argparse
import json
import sys
import numpy as np
from PIL import Image
from sklearn.cluster import KMeans

# ── Args ──────────────────────────────────────────────────────────────────────
parser = argparse.ArgumentParser()
parser.add_argument("image", help="Path to image")
parser.add_argument("--mode", choices=["dark", "light"], default="dark")
parser.add_argument("--clusters", type=int, default=8)
parser.add_argument("--contrast", type=float, default=0.0)
args = parser.parse_args()

# ── Load + sample image ───────────────────────────────────────────────────────
img = Image.open(args.image).convert("RGB")
img.thumbnail((300, 300))
pixels = np.array(img).reshape(-1, 3).astype(float)

# ── K-means clustering ────────────────────────────────────────────────────────
k = min(args.clusters, len(pixels))
km = KMeans(n_clusters=k, n_init=10, random_state=0)
km.fit(pixels)

labels, counts = np.unique(km.labels_, return_counts=True)
order = np.argsort(-counts)
centers = km.cluster_centers_[order].astype(int)

# ── Color utilities ───────────────────────────────────────────────────────────
def to_hex(rgb):
    rgb = np.clip(np.round(rgb), 0, 255).astype(int)
    return "#{:02x}{:02x}{:02x}".format(*rgb)

def luminance(rgb):
    r, g, b = [x / 255.0 for x in rgb]
    def lin(c): return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)

def saturation(rgb):
    r, g, b = np.array(rgb) / 255.0
    cmax, cmin = max(r, g, b), min(r, g, b)
    delta = cmax - cmin
    if cmax == 0: return 0
    return delta / cmax

def on_color(rgb):
    return np.array([15, 15, 18]) if luminance(rgb) > 0.3 else np.array([235, 235, 238])

def lighten(rgb, amount):
    return np.clip(np.array(rgb, float) + amount * 255, 0, 255)

def darken(rgb, amount):
    return np.clip(np.array(rgb, float) - amount * 255, 0, 255)

def mix(a, b, t):
    return np.clip(np.array(a, float) * (1 - t) + np.array(b, float) * t, 0, 255)

def color_distance(a, b):
    return np.sqrt(np.sum((np.array(a, float) - np.array(b, float)) ** 2))

# ── Pick 3 distinct, colorful clusters ───────────────────────────────────────
def score_color(rgb, already_chosen):
    sat = saturation(rgb)
    lum = luminance(rgb)
    lum_penalty = max(0, 0.85 - abs(lum - 0.5) * 1.7)
    min_dist = min((color_distance(rgb, c) for c in already_chosen), default=300)
    dist_bonus = min(min_dist / 300, 1.0)
    return sat * 0.5 + lum_penalty * 0.3 + dist_bonus * 0.2

chosen = []
remaining = list(centers)

for _ in range(3):
    if not remaining:
        break
    scores = [score_color(c, chosen) for c in remaining]
    best = remaining[np.argmax(scores)]
    chosen.append(best)
    remaining = [c for c in remaining if not np.array_equal(c, best)]

while len(chosen) < 3:
    chosen.append(chosen[-1])

primary, secondary, tertiary = chosen[0], chosen[1], chosen[2]

# ── Build dark/light variants ─────────────────────────────────────────────────
is_dark = args.mode == "dark"
c_shift = args.contrast * 25

if is_dark:
    bg        = np.clip(mix(primary, [12, 12, 16], 0.93) + c_shift * 0.2, 0, 255)
    surface   = np.clip(mix(primary, [18, 18, 22], 0.90) + c_shift * 0.15, 0, 255)
    surf_var  = np.clip(mix(primary, [35, 33, 40], 0.82) + c_shift * 0.1, 0, 255)
    p_col     = np.clip(lighten(primary,   0.30 + args.contrast * 0.08), 0, 255)
    s_col     = np.clip(lighten(secondary, 0.28 + args.contrast * 0.08), 0, 255)
    t_col     = np.clip(lighten(tertiary,  0.28 + args.contrast * 0.08), 0, 255)
    p_cont    = np.clip(mix(primary,   [30, 28, 36], 0.55), 0, 255)
    s_cont    = np.clip(mix(secondary, [28, 30, 36], 0.55), 0, 255)
    t_cont    = np.clip(mix(tertiary,  [30, 28, 34], 0.55), 0, 255)
else:
    bg        = np.clip(mix(primary, [248, 246, 252], 0.94) - c_shift * 0.2, 0, 255)
    surface   = np.clip(mix(primary, [242, 240, 248], 0.91) - c_shift * 0.15, 0, 255)
    surf_var  = np.clip(mix(primary, [218, 215, 226], 0.84) - c_shift * 0.1, 0, 255)
    p_col     = np.clip(darken(primary,   0.30 - args.contrast * 0.08), 0, 255)
    s_col     = np.clip(darken(secondary, 0.28 - args.contrast * 0.08), 0, 255)
    t_col     = np.clip(darken(tertiary,  0.28 - args.contrast * 0.08), 0, 255)
    p_cont    = np.clip(mix(primary,   [220, 218, 230], 0.55), 0, 255)
    s_cont    = np.clip(mix(secondary, [218, 220, 230], 0.55), 0, 255)
    t_cont    = np.clip(mix(tertiary,  [220, 218, 228], 0.55), 0, 255)

outline    = mix(surf_var, on_color(bg), 0.55)
out_var    = mix(surf_var, on_color(bg), 0.30)
err        = np.array([255, 180, 171]) if is_dark else np.array([186, 26, 26])
err_cont   = np.array([147, 0, 10])    if is_dark else np.array([255, 218, 214])

# ── Build role dict ───────────────────────────────────────────────────────────
def role(col):
    h = to_hex(col)
    alt = to_hex(lighten(col, 0.25) if is_dark else darken(col, 0.25))
    return {"dark": h if is_dark else alt, "default": h, "light": alt if is_dark else h}

colors = {
    "primary":                role(p_col),
    "on_primary":             role(on_color(p_col)),
    "primary_container":      role(p_cont),
    "on_primary_container":   role(on_color(p_cont)),
    "secondary":              role(s_col),
    "on_secondary":           role(on_color(s_col)),
    "secondary_container":    role(s_cont),
    "on_secondary_container": role(on_color(s_cont)),
    "tertiary":               role(t_col),
    "on_tertiary":            role(on_color(t_col)),
    "tertiary_container":     role(t_cont),
    "on_tertiary_container":  role(on_color(t_cont)),
    "background":             role(bg),
    "on_background":          role(on_color(bg)),
    "surface":                role(surface),
    "on_surface":             role(on_color(surface)),
    "surface_variant":        role(surf_var),
    "on_surface_variant":     role(on_color(surf_var)),
    "error":                  role(err),
    "on_error":               role(on_color(err)),
    "error_container":        role(err_cont),
    "on_error_container":     role(on_color(err_cont)),
    "outline":                role(outline),
    "outline_variant":        role(out_var),
    "shadow":                 {"dark": "#000000", "default": "#000000", "light": "#000000"},
    "inverse_surface":        role(on_color(bg)),
    "inverse_on_surface":     role(bg),
}

print(json.dumps({"colors": colors}, indent=2))
