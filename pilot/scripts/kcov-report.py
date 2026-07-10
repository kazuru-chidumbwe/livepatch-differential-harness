#!/usr/bin/env python3
"""Parse kcov QEMU serial output and estimate BB% for a vmlinux symbol."""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


def count_symbol_blocks(vmlinux: Path, symbol: str, ko: Path | None = None) -> tuple[int, int]:
    """Return (instruction_count, estimated_basic_blocks) via objdump."""
    targets = [vmlinux]
    if ko and ko.exists():
        targets.insert(0, ko)
    out = ""
    for target in targets:
        try:
            out = subprocess.check_output(
                ["objdump", "-d", str(target), f"--disassemble={symbol}"],
                text=True,
                errors="replace",
            )
            if "Disassembly of section" in out and symbol in out:
                break
        except subprocess.CalledProcessError:
            continue
    if not out:
        return 0, 0
    lines = [ln for ln in out.splitlines() if re.match(r"^\s+[0-9a-f]+:", ln)]
    blocks = len(re.findall(r"^[0-9a-f]+ <", out, re.M))
    if blocks == 0:
        blocks = max(1, len(lines) // 4) if lines else 0
    return len(lines), blocks


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--serial", required=True)
    ap.add_argument("--vmlinux", required=True)
    ap.add_argument("--symbol", default="version_proc_show")
    ap.add_argument("--ko", default="")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    serial = Path(args.serial).read_text(encoding="utf-8", errors="replace")
    m = re.search(r"KCOV_BB_HITS=(\d+)", serial)
    if not m:
        err = re.search(r"KCOV_ERR=(\S+)", serial)
        msg = err.group(1) if err else "no KCOV_BB_HITS in serial log"
        Path(args.out).write_text(
            f"# kcov report — FAILED\n\nReason: {msg}\n\nRaw excerpt:\n{serial[-2000:]}\n",
            encoding="utf-8",
        )
        print(f"kcov failed: {msg}", file=sys.stderr)
        return 1

    hits = int(m.group(1))
    vmlinux = Path(args.vmlinux)
    ko = Path(args.ko) if args.ko else None
    # Patched handler lives in the livepatch module, not vmlinux
    mod_sym = "hb_version_proc_show"
    insn, est_blocks = count_symbol_blocks(vmlinux, mod_sym, ko)
    if est_blocks == 0:
        pct_line = (
            "**Function-local BB %:** not computed (symbol not resolved). "
            f"Report **syscall-path BB hits only: {hits}**."
        )
    elif hits > max(est_blocks, 1) * 8:
        pct_line = (
            f"**Function-local BB %:** not meaningful as a ratio — **{hits}** syscall-path hits "
            f"vs **{insn}** instructions in `{mod_sym}` (callees dominate). "
            "Report syscall-path hits only; do not round up to a coverage percentage."
        )
    else:
        pct_upper = min(100.0, (hits / est_blocks) * 100.0)
        pct_line = (
            f"**Upper-bound vs `{mod_sym}` BB estimate:** {pct_upper:.1f}% "
            f"({hits} hits / {est_blocks} estimated BB). Actual function-local coverage is **≤ this value**."
        )

    text = f"""# LP-PILOT-02 kcov report

**Workload:** one `/proc/version` read after livepatch enabled
**KCOV_BB_HITS:** {hits} (kernel basic blocks during syscall — includes callees and livepatch glue)
**Replacement function:** `{mod_sym}` insn={insn}, estimated BB={est_blocks or 'n/a'}

{pct_line}

**Method:** `pilot/scripts/09-kcov-pilot-02.sh`, `CONFIG_KCOV=y`, `KCOV_TRACE_PC`.
"""
    Path(args.out).write_text(text, encoding="utf-8")
    print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
