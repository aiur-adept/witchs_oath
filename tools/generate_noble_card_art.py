#!/usr/bin/env python3
"""
One-shot / repeatable generator for symmetric Unicode box-drawing art per noble.
Run: python tools/generate_noble_card_art.py [--seed N] [--out PATH]

Default seed is fixed so re-running reproduces the same file unless you change the seed.
Committed noble_card_art.json is canonical; regenerate only when adding nobles or intentionally refreshing art.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
from pathlib import Path

# Must match ArcanaCpuBase.NOBLE_DEFS keys (15 nobles).
NOBLE_IDS: tuple[str, ...] = (
    "krss_power",
    "trss_power",
    "yrss_power",
    "xytzr_emanation",
    "yytzr_occultation",
    "zytzr_annihilation",
    "aeoiu_rituals",
    "sndrr_incantation",
    "indrr_incantation",
    "bndrr_incantation",
    "wndrr_incantation",
    "rndrr_incantation",
    "rmrsk_emanation",
    "smrsk_occultation",
    "tmrsk_annihilation",
)

# Horizontal mirror pairs (left glyph -> right glyph). Unlisted chars are assumed symmetric.
_MIRROR: dict[str, str] = {
    "┌": "┐",
    "┐": "┌",
    "└": "┘",
    "┘": "└",
    "╭": "╮",
    "╮": "╭",
    "╰": "╯",
    "╯": "╰",
    "├": "┤",
    "┤": "├",
    "╟": "╢",
    "╢": "╟",
    "/": "\\",
    "\\": "/",
    "(": ")",
    ")": "(",
    "[": "]",
    "]": "[",
    "<": ">",
    ">": "<",
    "{": "}",
    "}": "{",
}

# Glyphs safe on the vertical axis of symmetry (odd width).
_CENTER: frozenset[str] = frozenset(
    "─│┼·░▒═*+⊙◎○◆◇□▪▫ "
)

# Any glyph for off-axis positions.
_SIDE: tuple[str, ...] = tuple(
    "─│┌┐└┘╭╮╰╯├┤┬┴┼·░▒═*◇○◎◆▪"
)


def _mirror_ch(c: str) -> str:
    if c in _MIRROR:
        return _MIRROR[c]
    return c


def _symmetric_row(width: int, rng: random.Random) -> str:
    if width % 2 == 0:
        width += 1
    center = width // 2
    row = [" "] * width
    for i in range(center):
        c = rng.choice(_SIDE)
        row[i] = c
        row[width - 1 - i] = _mirror_ch(c)
    row[center] = rng.choice(tuple(_CENTER))
    return "".join(row)


def _make_block(width: int, rows: int, rng: random.Random) -> str:
    lines = [_symmetric_row(width, rng) for _ in range(rows)]
    return "\n".join(lines)


def _seed_for_noble(master: int, noble_id: str) -> int:
    h = hashlib.sha256(f"{master}\0{noble_id}".encode("utf-8")).digest()
    return int.from_bytes(h[:8], "big")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--seed",
        type=int,
        default=0x4E6F626C,
        help="Master seed (default: 0x4E6F626C ASCII 'Nobl')",
    )
    ap.add_argument("--width", type=int, default=11)
    ap.add_argument("--rows", type=int, default=7)
    ap.add_argument(
        "--out",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "data" / "noble_card_art.json",
    )
    args = ap.parse_args()

    out: dict[str, str] = {}
    for nid in NOBLE_IDS:
        rng = random.Random(_seed_for_noble(args.seed, nid))
        out[nid] = _make_block(args.width, args.rows, rng)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(
        json.dumps(out, ensure_ascii=False, indent="\t") + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(out)} entries to {args.out}")


if __name__ == "__main__":
    main()
