#!/usr/bin/env bash
# Run LP-PILOT-02 hand-build, validation, and loadable behavioral perturbation.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"

HB="$ROOT/pilot/handbuild/$HANDUILD_SUBDIR"
RES="$ROOT/pilot/results/LP-PILOT-02"
BZ="$ROOT/pilot/build/bzImage"
Q="$ROOT/pilot/build/qemu"
mkdir -p "$RES"

LOG="$RES/handbuild-failure.log"
: >"$LOG"
iter=0
while [ "$iter" -lt 5 ]; do
  iter=$((iter + 1))
  echo "--- iteration $iter ---" >>"$LOG"
  if make -C "$HB" clean KDIR="$WORK_ROOT/linux" >>"$LOG" 2>&1 && \
     make -C "$HB" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$WORK_ROOT/linux" >>"$LOG" 2>&1; then
    echo "$iter" >"$RES/handbuild-iterations.txt"
    break
  fi
done
[ "$iter" -le 5 ] && [ -f "$HB/${MODULE_BASENAME}.ko" ] || { tail -20 "$LOG"; exit 1; }

KO="$HB/${MODULE_BASENAME}.ko"
{
  echo "# LP-PILOT-02 relocation table"
  readelf -S "$KO" | grep -E 'rela|\.text' || true
  echo
  readelf -r "$KO" | grep -E 'R_X86_64|rela\.text' || true
} | tee "$HB/relocation-table.md" >"$RES/relocation-table.txt"

# --- QEMU good path ---
INIT="$Q/initrd-lp02"
rm -rf "$INIT"
mkdir -p "$INIT"/{bin,proc,sys,dev}
cp /bin/busybox "$INIT/bin/"
for a in sh mount cat poweroff insmod sleep; do ln -sf busybox "$INIT/bin/$a"; done
cp "$KO" "$INIT/"
cat > "$INIT/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "=== PRE_PATCH ==="
cat $PROC_FILE
insmod /${MODULE_BASENAME}.ko
echo "INSMOD_RC=\$?"
sleep 1
echo "=== POST_PATCH ==="
cat $PROC_FILE
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
echo 0 > /sys/kernel/livepatch/${SYSFS_NAME}/enabled 2>/dev/null || true
sleep 1
echo "=== POST_REVERT ==="
cat $PROC_FILE
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P3_PASS=0; else echo P3_PASS=1; fi
echo "=== DONE ==="
poweroff -f
INIT
chmod +x "$INIT/init"
( cd "$INIT" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/initrd-lp02.cpio.gz"
SERIAL_GOOD="$RES/qemu-serial-good.log"
: >"$SERIAL_GOOD"
timeout 90 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-lp02.cpio.gz" \
  -append "console=ttyS0 panic=1 nokaslr init=/init" -m 1024 -nographic -no-reboot \
  -serial file:"$SERIAL_GOOD" 2>/dev/null || true
cp "$SERIAL_GOOD" "$RES/validation.log"

# --- Loadable perturbation (rodata addend swap) ---
PERT="$HB/${MODULE_BASENAME}.perturbed.ko"
python3 "$ROOT/pilot/scripts/perturb-rodata-addend.py" "$KO" "$PERT"
INITP="$Q/initrd-lp02-perturb"
rm -rf "$INITP"
mkdir -p "$INITP"/{bin,proc,sys,dev}
cp /bin/busybox "$INITP/bin/"
for a in sh mount cat poweroff insmod sleep; do ln -sf busybox "$INITP/bin/$a"; done
cp "$PERT" "$INITP/${MODULE_BASENAME}.ko"
cat > "$INITP/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "=== PERTURB_LOADABLE ==="
insmod /${MODULE_BASENAME}.ko
echo "INSMOD_RC=\$?"
sleep 1
cat $PROC_FILE
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
poweroff -f
INIT
chmod +x "$INITP/init"
( cd "$INITP" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/initrd-lp02-perturb.cpio.gz"
SERIAL_P="$RES/perturbation-loadable-serial.log"
: >"$SERIAL_P"
timeout 60 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-lp02-perturb.cpio.gz" \
  -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
  -serial file:"$SERIAL_P" 2>/dev/null || true

{
  echo "# LP-PILOT-02 perturbation (loadable data-relocation — rodata addend swap)"
  echo
  echo "Claim under test: behavioral predicates detect a data-relocation error when insmod succeeds."
  echo "Not tested: mechanism #1 code-relocation / function-symbol substitution."
  echo
  grep -E 'PERTURB|INSMOD|P2_PASS|POST|PRE|DONE' "$SERIAL_P" || cat "$SERIAL_P"
} | tee "$RES/perturbation-loadable.txt"

echo "--- LP-PILOT-02 summary ---"
grep -E 'PRE_PATCH|POST_PATCH|POST_REVERT|P2_PASS|P3_PASS|INSMOD|DONE' "$SERIAL_GOOD" | tee "$RES/validation-summary.txt"

pass_good=0
pass_perturb=0
grep -q 'P2_PASS=1' "$SERIAL_GOOD" && grep -q 'P3_PASS=1' "$SERIAL_GOOD" && pass_good=1
grep -q 'INSMOD_RC=0' "$SERIAL_P" && grep -q 'P2_PASS=0' "$SERIAL_P" && pass_perturb=1

echo "GOOD_PATH=$pass_good PERTURB_BEHAVIORAL=$pass_perturb"
if [ "$pass_good" -eq 1 ] && [ "$pass_perturb" -eq 1 ]; then
  echo "LP-PILOT-02-PASS"
  exit 0
fi
echo "LP-PILOT-02-FAIL"
exit 1
