#!/usr/bin/env python3
"""Swap R_X86_64_PLT32 symbol indices for two named callees in .rela.text (code-relocation test)."""
from __future__ import annotations

import re
import struct
import subprocess
import sys
from pathlib import Path


def parse_plt32_symbols(ko: Path) -> dict[str, tuple[int, int]]:
    """Return sym_name -> (r_offset, sym_index) for PLT32 relocs."""
    out = subprocess.check_output(["readelf", "-rW", str(ko)], text=True, errors="replace")
    found: dict[str, tuple[int, int]] = {}
    for line in out.splitlines():
        if "R_X86_64_PLT32" not in line:
            continue
        m = re.match(
            r"^([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s+R_X86_64_PLT32\s+\S+\s+(\S+)\s+-\s+",
            line.strip(),
        )
        if not m:
            continue
        r_off = int(m.group(1), 16)
        info = int(m.group(2), 16)
        sym_name = m.group(3)
        sym_idx = info >> 32
        if sym_name not in found:
            found[sym_name] = (r_off, sym_idx)
    return found


def rela_entries(ko: Path) -> dict[int, int]:
    from elftools.elf.elffile import ELFFile
    from elftools.elf.relocation import RelocationSection

    with ko.open("rb") as f:
        elf = ELFFile(f)
        sec = elf.get_section_by_name(".rela.text")
        if sec is None or not isinstance(sec, RelocationSection):
            return {}
        entsize = sec.header["sh_entsize"] or 24
        base = sec.header["sh_offset"]
        return {rel["r_offset"]: base + i * entsize for i, rel in enumerate(sec.iter_relocations())}


def main() -> int:
    if len(sys.argv) < 4:
        print(f"usage: {sys.argv[0]} SRC.ko DST.ko SYM_A SYM_B", file=sys.stderr)
        return 2
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    sym_a, sym_b = sys.argv[3], sys.argv[4]
    plt = parse_plt32_symbols(src)
    if sym_a not in plt or sym_b not in plt:
        print(f"need PLT32 relocs for {sym_a} and {sym_b}; have {list(plt)}", file=sys.stderr)
        return 1
    off_a, idx_a = plt[sym_a]
    off_b, idx_b = plt[sym_b]
    fmap = rela_entries(src)
    ent_a, ent_b = fmap.get(off_a), fmap.get(off_b)
    if ent_a is None or ent_b is None:
        print("failed to map rela entries", file=sys.stderr)
        return 1

    data = bytearray(src.read_bytes())
    for ent, new_idx in ((ent_a, idx_b), (ent_b, idx_a)):
        info = struct.unpack_from("<Q", data, ent + 8)[0]
        r_type = info & 0xFFFFFFFF
        struct.pack_into("<Q", data, ent + 8, (new_idx << 32) | r_type)
    dst.write_bytes(data)
    print(f"swapped PLT32 {sym_a} (idx {idx_a}) <-> {sym_b} (idx {idx_b}) at {off_a:#x},{off_b:#x}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
