#!/usr/bin/env bash
# Dump relocation table for hand-built module (§4 deliverable).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
KO="$ROOT/pilot/handbuild/LP-PILOT-01/livepatch-cmdline.ko"
OUT="$ROOT/pilot/handbuild/LP-PILOT-01/relocation-table.md"
RES="$ROOT/pilot/results/relocation-table.txt"

if [[ ! -f "$KO" ]]; then
  echo "missing $KO — run 04-handbuild.sh first" >&2
  exit 1
fi

{
  echo "# LP-PILOT-01 relocation table"
  echo
  echo "**Module:** \`livepatch-cmdline.ko\`"
  echo "**Derivation method:** GNU readelf/objdump on built .ko; tuples normalized per"
  echo "[kernel livepatch ELF format](https://docs.kernel.org/livepatch/module-elf-format.html)."
  echo
  echo "## Sections"
  readelf -S "$KO" | grep -E 'klp|rela|livepatch' || true
  echo
  echo "## Relocations (readelf -r)"
  readelf -r "$KO" || true
  echo
  echo "## Relocations (objdump -r)"
  objdump -r "$KO" 2>/dev/null || true
} | tee "$OUT" >"$RES"

echo "wrote $OUT"
