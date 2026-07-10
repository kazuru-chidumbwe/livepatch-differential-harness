#!/usr/bin/env python3
"""Redirect all PLT32 relocs for SYM_SRC to SYM_DST symbol index (one-way)."""
from __future__ import annotations

import re
import struct
import subprocess
import sys
from pathlib import Path


def parse_plt32(ko: Path) -> dict[str, tuple[int, int]]:
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
        sym = m.group(3)
        if sym not in found:
            found[sym] = (int(m.group(1), 16), int(m.group(2), 16) >> 32)
    return found


def all_plt32_offsets(ko: Path, sym: str) -> list[int]:
    out = subprocess.check_output(["readelf", "-rW", str(ko)], text=True, errors="replace")
    offs: list[int] = []
    for line in out.splitlines():
        if "R_X86_64_PLT32" not in line or sym not in line:
            continue
        m = re.match(r"^([0-9a-fA-F]+)", line.strip())
        if m:
            offs.append(int(m.group(1), 16))
    return offs


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
    if len(sys.argv) != 5:
        print(f"usage: {sys.argv[0]} SRC.ko DST.ko SRC_SYM DST_SYM", file=sys.stderr)
        return 2
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    src_sym, dst_sym = sys.argv[3], sys.argv[4]
    plt = parse_plt32(src)
    if src_sym not in plt or dst_sym not in plt:
        print(f"need {src_sym} and {dst_sym}; have {list(plt)}", file=sys.stderr)
        return 1
    _, dst_idx = plt[dst_sym]
    fmap = rela_entries(src)
    data = bytearray(src.read_bytes())
    n = 0
    for roff in all_plt32_offsets(src, src_sym):
        ent = fmap.get(roff)
        if ent is None:
            continue
        info = struct.unpack_from("<Q", data, ent + 8)[0]
        r_type = info & 0xFFFFFFFF
        struct.pack_into("<Q", data, ent + 8, (dst_idx << 32) | r_type)
        n += 1
    dst.write_bytes(data)
    print(f"redirected {n} PLT32 site(s) {src_sym} -> {dst_sym} (idx {dst_idx})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
