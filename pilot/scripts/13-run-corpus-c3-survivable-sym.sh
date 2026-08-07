#!/usr/bin/env bash
# LP-CORPUS-03: survivable same-arity function redirect (seq_puts -> seq_putc).
#
# Ground truth for C3 is STRUCTURAL_BIND_PASS (wrong PLT32 callee while loadable).
# P2 checks patch-semantic expected marker string — not a coincidental glyph.
# The ASCII '!' side-effect on nokaslr pins is illustrative only (layout coincidence).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"

HB="$ROOT/pilot/handbuild/LP-CORPUS-03-seqputs"
RES="$ROOT/pilot/results/LP-CORPUS-03-survivable-sym"
BZ="$ROOT/pilot/build/bzImage"
Q="$ROOT/pilot/build/qemu"
MOD=livepatch-corpus03
mkdir -p "$RES" "$HB"

make -C "$HB" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$WORK_ROOT/linux"
KO="$HB/${MOD}.ko"
PERT="$HB/${MOD}.seqputs-to-putc.ko"
python3 "$ROOT/pilot/scripts/perturb-plt32-redirect.py" "$KO" "$PERT" seq_puts seq_putc

{
  echo "# LP-CORPUS-03 survivable function redirect"
  echo "Redirect: seq_puts PLT32 -> seq_putc (one-way; same register arity at call site)"
  echo
  echo "## Good PLT32"
  readelf -rW "$KO" | grep -E 'PLT32.*(seq_puts|seq_putc)' || true
  echo "## Perturbed PLT32"
  readelf -rW "$PERT" | grep -E 'PLT32.*(seq_puts|seq_putc)' || true
  echo
  echo "## Structural binding oracle (C3 ground truth)"
  python3 "$ROOT/pilot/scripts/verify-plt32-binding.py" --check-redirect \
    "$KO" "$PERT" seq_puts seq_putc
} | tee "$RES/relocation-diff.txt"

# Fail closed if structural oracle fails (before QEMU)
python3 "$ROOT/pilot/scripts/verify-plt32-binding.py" --check-redirect \
  "$KO" "$PERT" seq_puts seq_putc | tee "$RES/structural-bind.txt"
grep -q 'STRUCTURAL_BIND_PASS=1' "$RES/structural-bind.txt"

run_qemu() {
  local ko="$1" tag="$2"
  local init="$Q/initrd-c3-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep dmesg; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${MOD}.ko"
  cat > "$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
dmesg -c >/dev/null
echo "=== CORPUS_C3_${tag} ==="
insmod /${MOD}.ko
echo "INSMOD_RC=\$?"
sleep 1
echo "---DMESG---"
dmesg | tail -25
echo "---PROC---"
cat $PROC_FILE || echo PROC_READ_FAIL=\$?
# Semantic P2: expected patch marker must appear (patch contract), not a specific corrupt glyph.
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
poweroff -f
INIT
  chmod +x "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/initrd-c3-$tag.cpio.gz"
  local serial="$RES/${tag}-serial.log"
  : >"$serial"
  timeout 60 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-c3-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'CORPUS_C3|INSMOD|P2_PASS|#PF|Oops|PROC|DMESG|livepatch' "$serial" || tail -35 "$serial"
}

{
  echo "=== STRUCTURAL (required for C3 claim) ==="
  cat "$RES/structural-bind.txt"
  echo
  echo "=== GOOD (semantic P2 must PASS) ==="
  run_qemu "$KO" good
  echo
  echo "=== PERTURB_SEQPUTS_TO_PUTc (INSMOD=0 + semantic P2 must FAIL) ==="
  run_qemu "$PERT" perturb
} | tee "$RES/predicate-transcript.txt"

objdump -d -M intel "$KO" | grep -A25 'hb_version_proc_show>' | head -30 >"$RES/disasm-good.txt"
objdump -d -M intel "$PERT" | grep -A25 'hb_version_proc_show>' | head -30 >"$RES/disasm-perturb.txt"

# Refresh SoftwareX data pack from structural + predicate evidence
RES="$RES" python3 - <<'PY'
from pathlib import Path
import os
res = Path(os.environ["RES"])
bind = (res / "structural-bind.txt").read_text(errors="replace")
pred = (res / "predicate-transcript.txt").read_text(errors="replace")
reloc = (res / "relocation-diff.txt").read_text(errors="replace")
pack = res / "C3-DATA-PACK.md"
pack.write_text(
    "# C3 data pack — structural ground truth\n\n"
    "**Verification oracle:** `STRUCTURAL_BIND_PASS` from "
    "`pilot/scripts/verify-plt32-binding.py` "
    "(PLT32 sites that bound `seq_puts` in the good module bind `seq_putc` after redirect).\n\n"
    "**Not an oracle:** coincidental `/proc/version` glyphs (e.g. ASCII `!` under `nokaslr`). "
    "Those are layout-dependent side-effects; P2 checks the patch marker contract only.\n\n"
    "## Structural bind\n\n```\n"
    + bind.strip()
    + "\n```\n\n## Relocation triage\n\n```\n"
    + reloc.strip()
    + "\n```\n\n## Predicate transcript (semantic P2)\n\n```\n"
    + pred.strip()
    + "\n```\n"
)
print(f"wrote {pack}")
PY

echo "LP-CORPUS-03-DONE"
