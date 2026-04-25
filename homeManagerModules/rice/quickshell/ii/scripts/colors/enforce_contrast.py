#!/usr/bin/env python3
"""
enforce_contrast.py — post-process a wallust colors.json to ensure
terminal color pairs have sufficient perceptual contrast.

Usage:
    python3 enforce_contrast.py ~/.cache/wal/colors.json
    python3 enforce_contrast.py ~/.cache/wal/colors.json --min-contrast 4.5
    python3 enforce_contrast.py ~/.cache/wal/colors.json --dry-run

The script edits the file in-place (or prints the result with --dry-run).
Only PIL is required (already in your venv).
"""

import json
import sys
import math
import argparse
from pathlib import Path


# ── Color math ────────────────────────────────────────────────────────────────

def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def rgb_to_hex(r: int, g: int, b: int) -> str:
    return f"#{r:02x}{g:02x}{b:02x}"


def linearize(c: float) -> float:
    """sRGB channel → linear light."""
    c /= 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def relative_luminance(r: int, g: int, b: int) -> float:
    return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)


def contrast_ratio(c1: tuple, c2: tuple) -> float:
    l1 = relative_luminance(*c1)
    l2 = relative_luminance(*c2)
    lighter, darker = max(l1, l2), min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def rgb_to_hsl(r: int, g: int, b: int) -> tuple[float, float, float]:
    r_, g_, b_ = r / 255, g / 255, b / 255
    cmax, cmin = max(r_, g_, b_), min(r_, g_, b_)
    delta = cmax - cmin
    l = (cmax + cmin) / 2
    s = 0.0 if delta == 0 else delta / (1 - abs(2 * l - 1))
    if delta == 0:
        h = 0.0
    elif cmax == r_:
        h = 60 * (((g_ - b_) / delta) % 6)
    elif cmax == g_:
        h = 60 * (((b_ - r_) / delta) + 2)
    else:
        h = 60 * (((r_ - g_) / delta) + 4)
    return h, s, l


def hsl_to_rgb(h: float, s: float, l: float) -> tuple[int, int, int]:
    c = (1 - abs(2 * l - 1)) * s
    x = c * (1 - abs((h / 60) % 2 - 1))
    m = l - c / 2
    if   h < 60:  r_, g_, b_ = c, x, 0
    elif h < 120: r_, g_, b_ = x, c, 0
    elif h < 180: r_, g_, b_ = 0, c, x
    elif h < 240: r_, g_, b_ = 0, x, c
    elif h < 300: r_, g_, b_ = x, 0, c
    else:         r_, g_, b_ = c, 0, x
    return (
        max(0, min(255, round((r_ + m) * 255))),
        max(0, min(255, round((g_ + m) * 255))),
        max(0, min(255, round((b_ + m) * 255))),
    )


def adjust_lightness(hex_color: str, target_l: float) -> str:
    r, g, b = hex_to_rgb(hex_color)
    h, s, _ = rgb_to_hsl(r, g, b)
    return rgb_to_hex(*hsl_to_rgb(h, s, max(0.0, min(1.0, target_l))))


def enforce_pair(fg_hex: str, bg_hex: str, min_ratio: float) -> str:
    """
    Adjust fg_hex lightness until it contrasts enough against bg_hex.
    Tries both darkening and lightening, picks whichever needs less change.
    Returns the adjusted fg hex.
    """
    fg = hex_to_rgb(fg_hex)
    bg = hex_to_rgb(bg_hex)

    if contrast_ratio(fg, bg) >= min_ratio:
        return fg_hex  # already fine

    _, _, fg_l = rgb_to_hsl(*fg)
    _, _, bg_l = rgb_to_hsl(*bg)

    # Try lightening fg
    best_light = fg_hex
    for step in range(1, 51):
        candidate = adjust_lightness(fg_hex, fg_l + step * 0.02)
        if contrast_ratio(hex_to_rgb(candidate), bg) >= min_ratio:
            best_light = candidate
            break

    # Try darkening fg
    best_dark = fg_hex
    for step in range(1, 51):
        candidate = adjust_lightness(fg_hex, fg_l - step * 0.02)
        if contrast_ratio(hex_to_rgb(candidate), bg) >= min_ratio:
            best_dark = candidate
            break

    # Pick whichever moved less from original lightness
    _, _, ll = rgb_to_hsl(*hex_to_rgb(best_light))
    _, _, dl = rgb_to_hsl(*hex_to_rgb(best_dark))

    if best_light == fg_hex and best_dark == fg_hex:
        return fg_hex  # couldn't fix it

    if best_light == fg_hex:
        return best_dark
    if best_dark == fg_hex:
        return best_light

    # Both worked — pick whichever is closer in lightness to original
    return best_light if abs(ll - fg_l) <= abs(dl - fg_l) else best_dark


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Enforce contrast in wallust colors.json")
    parser.add_argument("path", help="Path to colors.json")
    parser.add_argument("--min-contrast", type=float, default=3.0,
                        help="Minimum WCAG contrast ratio (default: 3.0). "
                             "Use 4.5 for AA, 3.0 for large text / UI elements.")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print result to stdout instead of writing the file")
    args = parser.parse_args()

    path = Path(args.path)
    data = json.loads(path.read_text())

    c = data.get("colors", {})
    # Work on a flat name→hex dict
    colors = {f"color{i}": c.get(f"color{i}", "#000000") for i in range(16)}
    original = dict(colors)

    bg  = colors["color0"]   # terminal background
    fg  = colors["color15"]  # terminal foreground / bright white

    # ── Pairs that MUST contrast against the background ──────────────────
    # color0 = bg (dark),  color8 = bright black (should be visible on bg)
    # color1–6 = normal colors, color9–14 = bright variants
    # color7 = light fg, color15 = bright fg
    #
    # Key problematic pairs (fg color vs background color0):
    must_contrast_bg = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

    # ── Pairs that must contrast against each other (normal vs bright) ───
    # Each normal color vs its bright sibling should be distinguishable
    sibling_pairs = [(i, i + 8) for i in range(1, 8)]

    changed = []

    # Pass 1: enforce all foreground colors against background
    for i in must_contrast_bg:
        key = f"color{i}"
        fixed = enforce_pair(colors[key], bg, args.min_contrast)
        if fixed != colors[key]:
            changed.append(f"  color{i}: {colors[key]} → {fixed}  "
                           f"(contrast vs bg was {contrast_ratio(hex_to_rgb(colors[key]), hex_to_rgb(bg)):.2f}, "
                           f"now {contrast_ratio(hex_to_rgb(fixed), hex_to_rgb(bg)):.2f})")
            colors[key] = fixed

    # Pass 2: enforce each normal/bright sibling pair against each other
    for n, b in sibling_pairs:
        kn, kb = f"color{n}", f"color{b}"
        fixed = enforce_pair(colors[kb], colors[kn], args.min_contrast)
        if fixed != colors[kb]:
            changed.append(f"  color{b}: {colors[kb]} → {fixed}  "
                           f"(contrast vs color{n} was {contrast_ratio(hex_to_rgb(colors[kb]), hex_to_rgb(colors[kn])):.2f}, "
                           f"now {contrast_ratio(hex_to_rgb(fixed), hex_to_rgb(colors[kn])):.2f})")
            colors[kb] = fixed

    # Write back
    for i in range(16):
        data["colors"][f"color{i}"] = colors[f"color{i}"]
    # Also update special section
    data["special"]["background"] = colors["color0"]
    data["special"]["foreground"] = colors["color15"]
    data["special"]["cursor"]     = colors["color15"]

    result = json.dumps(data, indent=4)

    if args.dry_run:
        print(result)
        if changed:
            print("\n# Changes made:", file=sys.stderr)
            for c in changed: print(c, file=sys.stderr)
        else:
            print("# No changes needed", file=sys.stderr)
    else:
        path.write_text(result)
        if changed:
            print(f"enforce_contrast: adjusted {len(changed)} color(s):")
            for c in changed: print(c)
        else:
            print("enforce_contrast: all colors already meet contrast requirements")


if __name__ == "__main__":
    main()
