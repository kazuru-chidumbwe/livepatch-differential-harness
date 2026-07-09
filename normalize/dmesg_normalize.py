#!/usr/bin/env python3
"""Canonicalize dmesg excerpts for Channel 3 operational comparison."""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

# Strip common volatile tokens before diffing.
_PATTERNS = [
    (re.compile(r"\[\s*\d+\.\d+\]"), "[TS]"),
    (re.compile(r"\b\d{4}/\d{2}/\d{2}\b"), "DATE"),
    (re.compile(r"\b0x[0-9a-fA-F]+\b"), "ADDR"),
    (re.compile(r"\bCPU#\d+\b"), "CPU"),
    (re.compile(r"\bpid:\s*\d+"), "pid:PID"),
    (re.compile(r"\btgid:\s*\d+"), "tgid:TGID"),
]


def canonicalize(text: str) -> str:
    out = text
    for pattern, repl in _PATTERNS:
        out = pattern.sub(repl, out)
    lines = [ln.rstrip() for ln in out.splitlines()]
    return "\n".join(lines).strip() + "\n"


def hash_canonical(text: str) -> str:
    return hashlib.sha256(canonicalize(text).encode()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("dmesg", type=Path, nargs="?")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        sample = "[  12.345678] livepatch: transition complete\n"
        assert "TS" in canonicalize(sample)
        print("dmesg_normalize: self-test OK")
        return 0

    if not args.dmesg:
        parser.error("provide dmesg file or --self-test")

    text = args.dmesg.read_text(encoding="utf-8", errors="replace")
    print(canonicalize(text))
    return 0


if __name__ == "__main__":
    sys.exit(main())
