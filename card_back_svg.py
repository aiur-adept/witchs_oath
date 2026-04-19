"""Produce an SVG card back matching main_menu_card_back.gd but in a square.

Mirrors the pip placement algorithm from `_draw()` in main_menu_card_back.gd:
pips arranged on concentric rings (6 per ring cap), 15 total, grouped in
threes cycling through WHITE, SILVER, TEAL, PURPLE, GOLD. Renders each pip
as a hollow circle (stroke only) to match the 1px ring in the Godot version.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path

COLOR_TEAL = "#3ec4b0"
COLOR_PURPLE = "#b565d8"
COLOR_GOLD = "#e8c547"
COLOR_WHITE = "#f5f5f5"
COLOR_SILVER = "#8c919a"
GROUP_COLORS = [COLOR_WHITE, COLOR_SILVER, COLOR_TEAL, COLOR_PURPLE, COLOR_GOLD]

PIP_COUNT = 15
GROUP_SIZE = 3
PIP_ALPHA = 0.98


def build_svg(side: float = 512.0) -> str:
    w = h = float(side)
    cx, cy = w * 0.5, h * 0.5
    min_dim = min(w, h)
    step = min_dim * 0.17
    dot_r = max(3, min(14, int(round(min_dim * 0.06))))
    stroke_w = max(1.0, dot_r / 14.0) * 5.0

    parts: list[str] = []
    parts.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w:g}" height="{h:g}" '
        f'viewBox="0 0 {w:g} {h:g}">'
    )
    parts.append(f'  <rect width="{w:g}" height="{h:g}" fill="#000000"/>')

    remaining = PIP_COUNT
    ring = 1
    pip_index = 0
    while remaining > 0:
        cap = ring * 6
        take = min(remaining, cap)
        radius = ring * step
        for i in range(take):
            ang = math.tau * (i / take) - math.pi / 2.0
            px = cx + math.cos(ang) * radius
            py = cy + math.sin(ang) * radius
            group = (pip_index // GROUP_SIZE) % len(GROUP_COLORS)
            color = GROUP_COLORS[group]
            parts.append(
                f'  <circle cx="{px:.3f}" cy="{py:.3f}" r="{dot_r - 0.5:.3f}" '
                f'fill="none" stroke="{color}" stroke-width="{stroke_w:g}" '
                f'stroke-opacity="{PIP_ALPHA}"/>'
            )
            pip_index += 1
        remaining -= take
        ring += 1

    parts.append("</svg>")
    return "\n".join(parts) + "\n"


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("-o", "--output", type=Path, default=Path("card_back.svg"))
    p.add_argument("-s", "--size", type=float, default=512.0,
                   help="Side length of the square SVG in user units (default 512)")
    args = p.parse_args()
    args.output.write_text(build_svg(args.size), encoding="utf-8")
    print(f"Wrote {args.output} ({args.size:g}x{args.size:g})")


if __name__ == "__main__":
    main()
