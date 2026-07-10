#!/usr/bin/env bash
# Generate forensic artifacts: objdump disassembly diff (good vs perturbed .ko).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"

HB="$ROOT/pilot/handbuild/$HANDUILD_SUBDIR"
RES="$ROOT/pilot/results/LP-PILOT-02"
GOOD="$HB/${MODULE_BASENAME}.ko"
PERT="$HB/${MODULE_BASENAME}.perturbed.ko"

[ -f "$GOOD" ] || { echo "missing $GOOD"; exit 1; }
python3 "$ROOT/pilot/scripts/perturb-rodata-addend.py" "$GOOD" "$PERT"

OUT="$RES/disassembly-diff.txt"
{
  echo "# LP-PILOT-02 disassembly diff — good vs rodata-addend perturbation"
  echo
  echo "## Good module — .text (objdump -d)"
  objdump -d -M intel "$GOOD" | sed -n '/<hb_version_proc_show>:/,/^$/p' | head -80
  echo
  echo "## Perturbed module — .text (objdump -d)"
  objdump -d -M intel "$PERT" | sed -n '/<hb_version_proc_show>:/,/^$/p' | head -80
  echo
  echo "## .rela.text R_X86_64_32S addends"
  echo "### Good"
  readelf -rW "$GOOD" | awk '/\.rela\.text/,/^$/' | grep 32S || true
  echo "### Perturbed"
  readelf -rW "$PERT" | awk '/\.rela\.text/,/^$/' | grep 32S || true
  echo
  echo "## dmesg-relevant serial excerpts"
  for f in "$RES/validation-summary.txt" "$RES/perturbation-loadable.txt"; do
    [ -f "$f" ] && echo "### $f" && cat "$f" && echo
  done
} >"$OUT"
echo "wrote $OUT"
