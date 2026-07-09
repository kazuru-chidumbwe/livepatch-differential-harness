#!/usr/bin/env bash
# Structural normalizer smoke gate — no kernel required.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 normalize/elf_normalize.py --self-test
python3 normalize/dmesg_normalize.py --self-test
python3 classifier/matrix.py --self-test

echo "smoke: all self-tests passed"
