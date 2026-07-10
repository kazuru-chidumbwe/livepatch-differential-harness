#!/usr/bin/env bash
# Measure kcov basic-block hits on /proc/version read after LP-PILOT-02 patch.
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

KO="$HB/${MODULE_BASENAME}.ko"
[ -f "$KO" ] || { echo "missing $KO — run 08-run-lp-pilot-02.sh first"; exit 1; }

MEAS="$ROOT/pilot/tools/kcov-measure"
KDIR="$WORK_ROOT/linux"
gcc -static -O2 -o "$MEAS" "$ROOT/pilot/tools/kcov-measure.c" \
  -I"$KDIR/include/uapi" -I"$KDIR/arch/x86/include/uapi" -I"$KDIR/include" \
  -Wno-error 2>/dev/null || gcc -static -O2 -o "$MEAS" "$ROOT/pilot/tools/kcov-measure.c"

INIT="$Q/initrd-lp02-kcov"
rm -rf "$INIT"
mkdir -p "$INIT"/{bin,proc,sys,dev}
cp /bin/busybox "$INIT/bin/"
for a in sh mount cat poweroff insmod sleep; do ln -sf busybox "$INIT/bin/$a"; done
cp "$KO" "$INIT/"
cp "$MEAS" "$INIT/bin/kcov-measure"
cat > "$INIT/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t debugfs debug /sys/kernel/debug 2>/dev/null || true
insmod /${MODULE_BASENAME}.ko
sleep 1
/bin/sh -c '/bin/kcov-measure $PROC_FILE'
echo "=== KCOV_DONE ==="
poweroff -f
INIT
chmod +x "$INIT/init"
( cd "$INIT" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/initrd-lp02-kcov.cpio.gz"

SERIAL="$RES/kcov-serial.log"
: >"$SERIAL"
timeout 90 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-lp02-kcov.cpio.gz" \
  -append "console=ttyS0 panic=1 nokaslr init=/init" -m 1024 -nographic -no-reboot \
  -serial file:"$SERIAL" 2>/dev/null || true

python3 "$ROOT/pilot/scripts/kcov-report.py" \
  --serial "$SERIAL" \
  --vmlinux "$ROOT/pilot/build/vmlinux" \
  --ko "$KO" \
  --symbol "$OLD_FUNC" \
  --out "$RES/kcov-report.txt"

cat "$RES/kcov-report.txt"
