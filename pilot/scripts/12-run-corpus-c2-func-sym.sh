#!/usr/bin/env bash
# LP-CORPUS-02: function-symbol / PLT32 code-relocation perturbation twin.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"

HB="$ROOT/pilot/handbuild/$HANDUILD_SUBDIR"
RES="$ROOT/pilot/results/LP-CORPUS-02-func-sym"
BZ="$ROOT/pilot/build/bzImage"
Q="$ROOT/pilot/build/qemu"
mkdir -p "$RES"

KO="$HB/${MODULE_BASENAME}.ko"
[ -f "$KO" ] || bash "$ROOT/pilot/scripts/08-run-lp-pilot-02.sh"

PERT="$HB/${MODULE_BASENAME}.func-sym-perturbed.ko"
python3 "$ROOT/pilot/scripts/perturb-plt32-swap.py" "$KO" "$PERT" seq_printf seq_putc

{
  echo "# LP-CORPUS-02 function-symbol substitution (PLT32 swap)"
  echo
  echo "Mechanism: code-relocation — swap PLT32 bindings seq_printf <-> seq_putc"
  echo "Good reference: hand-build LP-PILOT-02"
  echo
  echo "## Relocations (good — excerpt)"
  readelf -rW "$KO" | awk '/\.rela\.text/,/^$/' | grep -E 'PLT32.*(seq_printf|seq_putc)' || true
  echo
  echo "## Relocations (perturbed — excerpt)"
  readelf -rW "$PERT" | awk '/\.rela\.text/,/^$/' | grep -E 'PLT32.*(seq_printf|seq_putc)' || true
} | tee "$RES/relocation-diff.txt"

run_qemu() {
  local ko="$1" tag="$2"
  local init="$Q/initrd-c2-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep dmesg; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${MODULE_BASENAME}.ko"
  cat > "$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
dmesg -c >/dev/null
echo "=== CORPUS_C2_${tag} ==="
insmod /${MODULE_BASENAME}.ko
echo "INSMOD_RC=\$?"
sleep 1
dmesg | tail -30
cat $PROC_FILE
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
poweroff -f
INIT
  chmod +x "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/initrd-c2-$tag.cpio.gz"
  local serial="$RES/${tag}-serial.log"
  : >"$serial"
  timeout 60 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-c2-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'CORPUS_C2|INSMOD|P2_PASS|livepatch|klp_|error|Error' "$serial" || tail -40 "$serial"
}

{
  echo "=== GOOD ==="
  run_qemu "$KO" good
  echo
  echo "=== PERTURB_PLT32 ==="
  run_qemu "$PERT" perturb
} | tee "$RES/predicate-transcript.txt"

objdump -d -M intel "$KO" | sed -n '/<hb_version_proc_show>:/,/^$/p' | head -40 >"$RES/disasm-good.txt"
objdump -d -M intel "$PERT" | sed -n '/<hb_version_proc_show>:/,/^$/p' | head -40 >"$RES/disasm-perturb.txt"

echo "LP-CORPUS-02-DONE"
