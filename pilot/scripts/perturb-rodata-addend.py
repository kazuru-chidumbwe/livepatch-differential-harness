#!/usr/bin/env python3
"""Swap two distinct R_X86_64_32S addends in .rela.text (loadable perturbation)."""
from __future__ import annotations

import re
import struct
import subprocess
import sys
from pathlib import Path


def parse_rela_text_32s(ko: Path) -> list[tuple[int, int]]:
    out = subprocess.check_output(["readelf", "-rW", str(ko)], text=True, errors="replace")
    in_text = False
    relocs: list[tuple[int, int]] = []
    for line in out.splitlines():
        if line.startswith("Relocation section ") and ".rela.text" in line:
            in_text = True
            continue
        if in_text and line.startswith("Relocation section "):
            break
        if not in_text:
            continue
        m = re.search(
            r"^([0-9a-fA-F]+)\s+[0-9a-fA-F]+\s+R_X86_64_32S\s+[0-9a-fA-F]+\s+\S+\s+\+\s*(-?[0-9a-fA-F]+)",
            line.strip(),
        )
        if not m:
            continue
        off = int(m.group(1), 16)
        addend = int(m.group(2), 16)
        relocs.append((off, addend))
    return relocs


def rela_file_offsets(ko: Path) -> dict[int, int]:
    from elftools.elf.elffile import ELFFile
    from elftools.elf.relocation import RelocationSection

    with ko.open("rb") as f:
        elf = ELFFile(f)
        sec = elf.get_section_by_name(".rela.text")
        if sec is None or not isinstance(sec, RelocationSection):
            return {}
        entsize = sec.header["sh_entsize"] or 24
        base = sec.header["sh_offset"]
        out: dict[int, int] = {}
        for i, rel in enumerate(sec.iter_relocations()):
            out[rel["r_offset"]] = base + i * entsize
        return out


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} SRC.ko DST.ko", file=sys.stderr)
        return 2
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    data = bytearray(src.read_bytes())
    relocs = parse_rela_text_32s(src)
    if len(relocs) < 2:
        print(f"need >=2 R_X86_64_32S relocs, got {len(relocs)}", file=sys.stderr)
        return 1
    by_addend: dict[int, int] = {}
    for r_off, add in relocs:
        if add not in by_addend:
            by_addend[add] = r_off
    if len(by_addend) < 2:
        print("need 2 distinct addends", file=sys.stderr)
        return 1
    file_map = rela_file_offsets(src)
    adds = sorted(by_addend.keys())[:2]
    a_roff, b_roff = by_addend[adds[0]], by_addend[adds[1]]
    a_ent = file_map.get(a_roff)
    b_ent = file_map.get(b_roff)
    if a_ent is None or b_ent is None:
        print("failed to map rela file offsets", file=sys.stderr)
        return 1
    struct.pack_into("<q", data, a_ent + 16, adds[1])
    struct.pack_into("<q", data, b_ent + 16, adds[0])
    dst.write_bytes(data)
    print(f"swapped addends {adds[0]} <-> {adds[1]} (r_offset {a_roff:#x},{b_roff:#x})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
