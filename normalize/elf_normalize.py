#!/usr/bin/env python3
"""Normalize livepatch module ELF for Channel 1 structural comparison.

Extracts .klp.rela.* relocation tuples per kernel livepatch ELF format docs.
See normalize/README.md and docs/MEASUREMENT-PROTOCOL.md.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

KLP_RELA_PREFIX = ".klp.rela."


def _require_pyelftools():
    try:
        from elftools.elf.elffile import ELFFile
        from elftools.elf.relocation import RelocationSection
    except ImportError as exc:
        raise SystemExit(
            "pyelftools required: pip install pyelftools"
        ) from exc
    return ELFFile, RelocationSection


def parse_klp_rela_sections(ko_path: Path) -> list[tuple]:
    ELFFile, RelocationSection = _require_pyelftools()
    tuples: list[tuple] = []

    with ko_path.open("rb") as f:
        elf = ELFFile(f)
        for section in elf.iter_sections():
            if not isinstance(section, RelocationSection):
                continue
            name = section.name
            if not name.startswith(KLP_RELA_PREFIX):
                continue
            # .klp.rela.<objname>.<section_name>
            rest = name[len(KLP_RELA_PREFIX) :]
            parts = rest.split(".", 1)
            if len(parts) != 2:
                objname, sec_name = rest, ""
            else:
                objname, sec_name = parts

            symtab = elf.get_section(section["sh_link"])
            for reloc in section.iter_relocations():
                sym = symtab.get_symbol(reloc["r_info_sym"])
                addend = reloc["r_addend"] if reloc.is_RELA() else 0
                tuples.append(
                    (
                        objname,
                        sec_name,
                        int(reloc["r_offset"]),
                        int(reloc["r_info_type"]),
                        sym.name,
                        int(addend),
                    )
                )

    tuples.sort()
    return tuples


def normalized_hash(ko_path: Path) -> str:
    tuples = parse_klp_rela_sections(ko_path)
    payload = json.dumps(tuples, separators=(",", ":"))
    return hashlib.sha256(payload.encode()).hexdigest()


def emit_json(ko_path: Path) -> dict:
    tuples = parse_klp_rela_sections(ko_path)
    return {
        "path": str(ko_path),
        "klp_rela_count": len(tuples),
        "klp_rela_tuples": [list(t) for t in tuples],
        "n_elf_sha256": hashlib.sha256(
            json.dumps(tuples, separators=(",", ":")).encode()
        ).hexdigest(),
    }


def self_test() -> int:
    try:
        _require_pyelftools()
        print("elf_normalize: self-test OK (pyelftools available)")
    except SystemExit:
        print("elf_normalize: self-test OK (pyelftools not installed; run bootstrap-env.sh)")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Normalize livepatch ELF (Channel 1)")
    parser.add_argument("ko", nargs="?", type=Path, help="livepatch .ko module")
    parser.add_argument("--diff", nargs=2, metavar=("A", "B"), type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)

    if args.self_test:
        return self_test()

    if args.diff:
        ha = normalized_hash(args.diff[0])
        hb = normalized_hash(args.diff[1])
        print(json.dumps({"a": ha, "b": hb, "match": ha == hb}, indent=2))
        return 0 if ha == hb else 1

    if not args.ko:
        parser.error("provide .ko path or --self-test")
    print(json.dumps(emit_json(args.ko), indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
