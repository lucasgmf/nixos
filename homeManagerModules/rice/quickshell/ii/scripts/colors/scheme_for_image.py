#!/usr/bin/env python3
"""
Smart scheme selector for switchwall.sh
Uses only PIL (pillow) — no cv2 dependency.

Analyzes image color properties to pick the most fitting matugen scheme.

Scheme reference:
  scheme-tonal-spot   → balanced, versatile (good default)
  scheme-expressive   → colorful, high-contrast, vivid
  scheme-fidelity     → stays very close to the source colors
  scheme-content      → faithful to image, less chroma boost
  scheme-neutral      → desaturated, subtle
  scheme-monochrome   → near-grayscale
  scheme-rainbow      → multi-hue, high variety
  scheme-fruit-salad  → analogous multi-hue (cool/warm split)
"""
import sys
import math
from PIL import Image


def load_and_resize(img_path, max_dim=192):
    img = Image.open(img_path).convert("RGB")
    w, h = img.size
    if max(w, h) > max_dim:
        scale = max_dim / max(w, h)
        img = img.resize(
            (max(1, int(w * scale)), max(1, int(h * scale))), Image.LANCZOS
        )
    return img


def rgb_to_hsv(r, g, b):
    """Pure-python RGB (0-255) -> HSV (h: 0-360, s: 0-1, v: 0-1)."""
    r, g, b = r / 255.0, g / 255.0, b / 255.0
    cmax, cmin = max(r, g, b), min(r, g, b)
    delta = cmax - cmin
    if delta == 0:
        h = 0.0
    elif cmax == r:
        h = 60.0 * (((g - b) / delta) % 6)
    elif cmax == g:
        h = 60.0 * (((b - r) / delta) + 2)
    else:
        h = 60.0 * (((r - g) / delta) + 4)
    s = 0.0 if cmax == 0 else delta / cmax
    v = cmax
    return h, s, v


def analyze(img):
    try:
        pixels = list(img.get_flattened_data())
    except AttributeError:
        pixels = list(img.getdata())

    colorful_hues = []
    colorful_sats = []
    rg_vals = []
    yb_vals = []

    for r, g, b in pixels:
        rg_vals.append(abs(r - g))
        yb_vals.append(abs(0.5 * (r + g) - b))
        h, s, v = rgb_to_hsv(r, g, b)
        if s > 0.15 and v > 0.10 and v < 0.95:
            colorful_hues.append(h)
            colorful_sats.append(s)

    def mean(lst):
        return sum(lst) / len(lst) if lst else 0.0

    def std(lst):
        if len(lst) < 2:
            return 0.0
        m = mean(lst)
        return math.sqrt(sum((x - m) ** 2 for x in lst) / len(lst))

    colorfulness = math.sqrt(std(rg_vals) ** 2 + std(yb_vals) ** 2) + 0.3 * math.sqrt(
        mean(rg_vals) ** 2 + mean(yb_vals) ** 2
    )

    dominant_sat = mean(colorful_sats)

    if len(colorful_hues) < 50:
        hue_spread = 0.0
        n_hue_clusters = 1
    else:
        hue_mean = mean(colorful_hues)
        hue_spread = math.sqrt(
            sum((h - hue_mean) ** 2 for h in colorful_hues) / len(colorful_hues)
        )
        bins = [0] * 24
        for h in colorful_hues:
            bins[int(h / 15) % 24] += 1
        threshold = len(colorful_hues) * 0.03
        n_hue_clusters = sum(1 for b in bins if b > threshold)

    return {
        "colorfulness": colorfulness,
        "hue_spread": hue_spread,
        "n_hue_clusters": n_hue_clusters,
        "dominant_sat": dominant_sat,
    }


def pick_scheme(colorfulness, hue_spread, n_hue_clusters, dominant_sat):
    if colorfulness < 15:
        return "scheme-monochrome"
    if colorfulness < 35:
        # Low colorfulness but multiple hue clusters = muted/painterly image,
        # scheme-content respects those subtle tones better than scheme-neutral
        if n_hue_clusters >= 4 and dominant_sat > 0.25:
            return "scheme-content"
        return "scheme-neutral" if dominant_sat > 0.25 else "scheme-monochrome"
    if n_hue_clusters >= 6:
        return "scheme-rainbow" if colorfulness > 80 else "scheme-fruit-salad"
    if colorfulness > 90 and n_hue_clusters <= 3:
        return "scheme-expressive" if dominant_sat > 0.6 else "scheme-fidelity"
    if colorfulness > 55:
        return "scheme-fruit-salad" if hue_spread > 35 else "scheme-tonal-spot"
    return "scheme-content" if dominant_sat > 0.35 else "scheme-neutral"


def main():
    debug_mode = False
    colorfulness_mode = False
    args = sys.argv[1:]

    if "--colorfulness" in args:
        colorfulness_mode = True
        args.remove("--colorfulness")
    if "--debug" in args:
        debug_mode = True
        args.remove("--debug")

    if not args:
        print("scheme-tonal-spot")
        sys.exit(1)

    try:
        img = load_and_resize(args[0])
    except Exception:
        print("scheme-tonal-spot")
        sys.exit(1)

    props = analyze(img)

    if colorfulness_mode:
        print(f"{props['colorfulness']:.2f}")
        return

    scheme = pick_scheme(**props)

    if debug_mode:
        for k, v in props.items():
            print(f"{k:<20}: {v:.3f}", file=sys.stderr)
        print(f"{'-> scheme':<20}: {scheme}", file=sys.stderr)

    print(scheme)


if __name__ == "__main__":
    main()
