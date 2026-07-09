#!/usr/bin/env python3
"""Aggregate channel outcomes into patch × tool matrix and artifact manifest."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any

OUTCOMES = ("PASS", "DIVERGE", "INCONCLUSIVE", "N/A")


class Outcome(str, Enum):
    PASS = "PASS"
    DIVERGE = "DIVERGE"
    INCONCLUSIVE = "INCONCLUSIVE"
    NA = "N/A"


@dataclass
class CellRecord:
    patch_id: str
    tool_id: str
    channel_1: Outcome
    channel_2: Outcome
    channel_3: Outcome

    @property
    def cell_outcome(self) -> Outcome:
        channels = [self.channel_1, self.channel_2, self.channel_3]
        if any(c == Outcome.DIVERGE for c in channels):
            return Outcome.DIVERGE
        required = [c for c in channels if c != Outcome.NA]
        if any(c == Outcome.INCONCLUSIVE for c in required):
            return Outcome.INCONCLUSIVE
        if required and all(c == Outcome.PASS for c in required):
            return Outcome.PASS
        return Outcome.INCONCLUSIVE

    def to_dict(self) -> dict[str, Any]:
        return {
            "patch_id": self.patch_id,
            "tool_id": self.tool_id,
            "channel_1": self.channel_1.value,
            "channel_2": self.channel_2.value,
            "channel_3": self.channel_3.value,
            "cell_outcome": self.cell_outcome.value,
        }


def aggregate_cell(ch1: str, ch2: str, ch3: str) -> str:
    cell = CellRecord(
        patch_id="",
        tool_id="",
        channel_1=Outcome(ch1),
        channel_2=Outcome(ch2),
        channel_3=Outcome(ch3),
    )
    return cell.cell_outcome.value


def write_matrix(cells: list[CellRecord], out_csv: Path) -> None:
    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "patch_id",
                "tool_id",
                "channel_1",
                "channel_2",
                "channel_3",
                "cell_outcome",
            ],
        )
        writer.writeheader()
        for cell in cells:
            writer.writerow(cell.to_dict())


def write_manifest(cells: list[CellRecord], out_json: Path, meta: dict) -> None:
    out_json.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "manifest_version": 1,
        "meta": meta,
        "cells": [c.to_dict() for c in cells],
    }
    out_json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def self_test() -> int:
    assert aggregate_cell("PASS", "PASS", "PASS") == "PASS"
    assert aggregate_cell("PASS", "DIVERGE", "PASS") == "DIVERGE"
    assert aggregate_cell("PASS", "INCONCLUSIVE", "PASS") == "INCONCLUSIVE"
    assert aggregate_cell("N/A", "PASS", "PASS") == "PASS"
    print("matrix: self-test OK")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--input", type=Path, help="JSON list of cell records")
    parser.add_argument("--out-dir", type=Path, default=Path("results"))
    args = parser.parse_args()

    if args.self_test:
        return self_test()

    if not args.input:
        parser.error("provide --input or --self-test")

    raw = json.loads(args.input.read_text(encoding="utf-8"))
    cells = [
        CellRecord(
            patch_id=r["patch_id"],
            tool_id=r["tool_id"],
            channel_1=Outcome(r["channel_1"]),
            channel_2=Outcome(r["channel_2"]),
            channel_3=Outcome(r["channel_3"]),
        )
        for r in raw
    ]
    write_matrix(cells, args.out_dir / "matrix.csv")
    write_manifest(cells, args.out_dir / "artifact-manifest.json", meta={"source": str(args.input)})
    print(f"wrote {args.out_dir / 'matrix.csv'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
