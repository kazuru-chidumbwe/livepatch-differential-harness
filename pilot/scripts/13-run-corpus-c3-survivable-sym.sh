#!/usr/bin/env bash
# LP-CORPUS-03: survivable same-arity function redirect (seq_puts -> seq_putc).
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
} | tee "$RES/relocation-diff.txt"

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
  echo "=== GOOD ==="
  run_qemu "$KO" good
  echo
  echo "=== PERTURB_SEQPUTS_TO_PUTc ==="
  run_qemu "$PERT" perturb
} | tee "$RES/predicate-transcript.txt"

objdump -d -M intel "$KO" | grep -A25 'hb_version_proc_show>' | head -30 >"$RES/disasm-good.txt"
objdump -d -M intel "$PERT" | grep -A25 'hb_version_proc_show>' | head -30 >"$RES/disasm-perturb.txt"

echo "LP-CORPUS-03-DONE"
