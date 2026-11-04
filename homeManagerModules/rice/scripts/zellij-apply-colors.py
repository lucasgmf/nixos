#!/usr/bin/env python3
import json
import re
import sys
import os

COLORS_PATH = os.path.expanduser("~/.local/state/quickshell/user/generated/colors.json")
CONFIG_PATH = os.path.expanduser("~/.config/zellij/config.kdl")


def boost_saturation(hex_color, amount):
    hex_color = hex_color.lstrip("#")
    r, g, b = [int(hex_color[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    max_c, min_c = max(r, g, b), min(r, g, b)
    l = (max_c + min_c) / 2
    if max_c == min_c:
        h, s = 0, 0
    else:
        d = max_c - min_c
        s = d / (2 - max_c - min_c) if l > 0.5 else d / (max_c + min_c)
        if max_c == r:
            h = (g - b) / d + (6 if g < b else 0)
        elif max_c == g:
            h = (b - r) / d + 2
        else:
            h = (r - g) / d + 4
        h /= 6
    s = min(1, s + amount)
    if s == 0:
        nr, ng, nb = l, l, l
    else:

        def hue2rgb(p, q, t):
            if t < 0:
                t += 1
            if t > 1:
                t -= 1
            if t < 1 / 6:
                return p + (q - p) * 6 * t
            if t < 1 / 2:
                return q
            if t < 2 / 3:
                return p + (q - p) * (2 / 3 - t) * 6
            return p

        q = l * (1 + s) if l < 0.5 else l + s - l * s
        p = 2 * l - q
        nr = hue2rgb(p, q, h + 1 / 3)
        ng = hue2rgb(p, q, h)
        nb = hue2rgb(p, q, h - 1 / 3)
    return "#{:02x}{:02x}{:02x}".format(
        round(nr * 255), round(ng * 255), round(nb * 255)
    )


def main():
    if not os.path.exists(COLORS_PATH):
        print(f"Colors file not found: {COLORS_PATH}", file=sys.stderr)
        sys.exit(1)

    with open(COLORS_PATH) as f:
        c = json.load(f)

    sat = 0.3

    color_map = {
        "color_rosewater": c["primary_fixed"],
        "color_flamingo": c["tertiary_fixed"],
        "color_pink": c["on_primary_container"],
        "color_mauve": boost_saturation(c["secondary_fixed"], sat),
        "color_red": c["error"],
        "color_maroon": c["on_error_container"],
        "color_peach": c["on_secondary_container"],
        "color_yellow": c["on_tertiary_container"],
        "color_green": boost_saturation(c["tertiary_fixed"], sat),
        "color_teal": boost_saturation(c["secondary_fixed_dim"], sat),
        "color_sky": boost_saturation(c["tertiary_fixed_dim"], sat),
        "color_sapphire": boost_saturation(c["secondary_fixed_dim"], sat),
        "color_blue": boost_saturation(c["primary_fixed_dim"], sat),
        "color_lavender": c["primary_fixed"],
        "color_text": c["on_background"],
        "color_subtext1": c["on_surface"],
        "color_subtext0": c["on_surface_variant"],
        "color_overlay2": c["on_surface_variant"],
        "color_overlay1": c["outline"],
        "color_overlay0": c["outline_variant"],
        "color_surface2": c["surface_container_highest"],
        "color_surface1": c["surface_container_high"],
        "color_surface0": c["surface_container"],
        "color_base": c["background"],
        "color_mantle": c["surface_container_low"],
        "color_crust": c["surface_container_lowest"],
    }

    with open(CONFIG_PATH) as f:
        content = f.read()

    def replace_color(match):
        key = match.group(1)
        if key in color_map:
            return f'        {key} "{color_map[key]}"'
        return match.group(0)

    new_content = re.sub(
        r'        (color_\w+) "#[0-9a-fA-F]{6}"', replace_color, content
    )

    # Write zellij theme with terminal background
    theme_bg = c["background"]
    theme_fg = c["on_background"]
    theme_block = f"""
themes {{
    material {{
        bg "{theme_bg}"
        fg "{theme_fg}"
        black "{c['surface_container_lowest']}"
        red "{c['error']}"
        green "{c['tertiary_fixed']}"
        yellow "{c['on_tertiary_container']}"
        blue "{c['primary_fixed_dim']}"
        magenta "{c['on_primary_container']}"
        cyan "{c['secondary_fixed_dim']}"
        white "{c['on_background']}"
        orange "{c['on_secondary_container']}"
    }}
}}
theme "material"
"""
    # Append or replace theme block in config
    new_content = re.sub(
        r'\nthemes \{.*?\}\ntheme "[^"]*"', theme_block, new_content, flags=re.DOTALL
    )
    if "themes {" not in new_content:
        new_content += theme_block

    with open(CONFIG_PATH, "w") as f:
        f.write(new_content)
    print("Zellij colors updated successfully!")


if __name__ == "__main__":
    main()
