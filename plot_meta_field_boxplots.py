"""Box plots of each deck's expected match points vs the field from meta CSV.

Reads a matrix where cell (row, col) is expected MP for the column deck as P1
vs the row deck as P0 (same convention as sim.meta output).

Usage (repo root):
    python plot_meta_field_boxplots.py
    python plot_meta_field_boxplots.py --csv meta_trained.csv -o meta_field_boxplots.png
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

import matplotlib.pyplot as plt


def load_column_distributions(path: Path) -> tuple[list[str], list[list[float]]]:
    with path.open(newline="", encoding="utf-8") as f:
        rows = list(csv.reader(f))
    if not rows:
        return [], []
    header = rows[0]
    if not header or header[0].strip() == "":
        raise ValueError("CSV missing header row")
    col_names = [c.strip() for c in header[1:]]
    per_deck: dict[str, list[float]] = {name: [] for name in col_names}
    for row in rows[1:]:
        if not row or not row[0].strip():
            continue
        for j, name in enumerate(col_names):
            k = j + 1
            if k >= len(row):
                continue
            s = row[k].strip()
            if s:
                per_deck[name].append(float(s))
    data = [per_deck[n] for n in col_names]
    return col_names, data


def main() -> None:
    ap = argparse.ArgumentParser(description="Box plots: each deck vs the field (meta CSV)")
    ap.add_argument(
        "--csv",
        type=Path,
        default=Path(__file__).resolve().parent / "meta_trained.csv",
        help="meta matrix CSV (default: ./meta_trained.csv next to this script)",
    )
    ap.add_argument(
        "-o",
        "--out",
        type=Path,
        default=None,
        help="save figure to this path (PNG/SVG/PDF); if omitted, show interactively",
    )
    ap.add_argument("--figwidth", type=float, default=0.65, help="width per deck (inches)")
    ap.add_argument("--figheight", type=float, default=6.0)
    args = ap.parse_args()

    names, data = load_column_distributions(args.csv)
    if not names:
        raise SystemExit(f"no data in {args.csv}")

    n = len(names)
    fig, ax = plt.subplots(figsize=(max(8.0, args.figwidth * n), args.figheight))
    ax.boxplot(data, patch_artist=True, medianprops={"color": "black", "linewidth": 1.5})
    ax.set_xticks(range(1, n + 1))
    ax.set_xticklabels(names, rotation=40, ha="right")
    ax.set_ylabel("Expected match points (3 / 1 / 0)")
    ax.set_xlabel("Deck (P1; one sample per P0 opponent in the meta)")
    ax.set_title("Matchup spread vs the field — " + args.csv.name)
    ax.grid(axis="y", linestyle=":", alpha=0.5)
    fig.tight_layout()

    if args.out:
        fig.savefig(args.out, dpi=150, bbox_inches="tight")
    else:
        plt.show()


if __name__ == "__main__":
    main()
