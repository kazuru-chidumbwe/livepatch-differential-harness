#!/usr/bin/env python3
"""Structural PLT32 binding checks for loadable livepatch mutants.

C3 verification must assert the wrong callee binding, not a contingent
observable glyph (ASCII '!' is a layout coincidence on nokaslr pins).

Usage:
  verify-plt32-binding.py --check-redirect GOOD.ko PERT.ko SRC_SYM DST_SYM

Exit 0 and print STRUCTURAL_BIND_PASS=1 when every PLT32 site that bound
SRC_SYM in GOOD binds DST_SYM in PERT (and GOOD still binds SRC_SYM).
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


def plt32_sites(ko: Path) -> list[tuple[int, str]]:
    """Return (r_offset, symbol) for each R_X86_64_PLT32 relocation."""
    out = subprocess.check_output(["readelf", "-rW", str(ko)], text=True, errors="replace")
    sites: list[tuple[int, str]] = []
    for line in out.splitlines():
        if "R_X86_64_PLT32" not in line:
            continue
        m = re.match(
            r"^([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+R_X86_64_PLT32\s+\S+\s+(\S+)\s+",
            line.strip(),
        )
        if m:
            sites.append((int(m.group(1), 16), m.group(2)))
    return sites


def sites_for_symbol(ko: Path, sym: str) -> list[int]:
    return [off for off, s in plt32_sites(ko) if s == sym]


def symbol_at(ko: Path, offset: int) -> str | None:
    for off, sym in plt32_sites(ko):
        if off == offset:
            return sym
    return None


def check_redirect(good: Path, pert: Path, src_sym: str, dst_sym: str) -> int:
    src_offs = sites_for_symbol(good, src_sym)
    if not src_offs:
        print("STRUCTURAL_BIND_PASS=0", flush=True)
        print(f"error: no PLT32 sites for {src_sym} in {good}", file=sys.stderr)
        return 1

    failures: list[str] = []
    for off in src_offs:
        g = symbol_at(good, off)
        p = symbol_at(pert, off)
        if g != src_sym:
            failures.append(f"0x{off:x}: good bound {g!r}, expected {src_sym!r}")
        if p != dst_sym:
            failures.append(f"0x{off:x}: pert bound {p!r}, expected {dst_sym!r}")

    print("# structural PLT32 redirect check")
    print(f"good={good}")
    print(f"pert={pert}")
    print(f"redirect={src_sym}->{dst_sym}")
    print(f"sites={','.join(f'0x{o:x}' for o in src_offs)}")
    for off in src_offs:
        print(f"offset=0x{off:x} good={symbol_at(good, off)} pert={symbol_at(pert, off)}")

    if failures:
        print("STRUCTURAL_BIND_PASS=0", flush=True)
        for f in failures:
            print(f"fail: {f}", file=sys.stderr)
        return 1

    print("STRUCTURAL_BIND_PASS=1", flush=True)
    print(
        "note: runtime observables (including coincidental glyphs) are illustrative only; "
        "this check is the C3 ground-truth oracle.",
        flush=True,
    )
    return 0


def main() -> int:
    if len(sys.argv) == 6 and sys.argv[1] in ("--check-redirect", "check-redirect"):
        return check_redirect(Path(sys.argv[2]), Path(sys.argv[3]), sys.argv[4], sys.argv[5])
    print(
        "usage: verify-plt32-binding.py --check-redirect GOOD.ko PERT.ko SRC DST",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
