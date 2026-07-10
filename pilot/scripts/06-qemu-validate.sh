#!/usr/bin/env bash
# Build minimal initrd and run QEMU behavioral + revert validation.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
KO="$ROOT/pilot/handbuild/LP-PILOT-01/livepatch-cmdline.ko"
BZ="$ROOT/pilot/build/bzImage"
RES="$ROOT/pilot/results"
QEMU_DIR="$ROOT/pilot/build/qemu"
INITRD_DIR="$QEMU_DIR/initrd-tree"
SERIAL="$RES/qemu-serial.log"
VALID="$RES/validation.log"

mkdir -p "$RES" "$INITRD_DIR"/{bin,sbin,proc,sys,dev,lib,lib64,usr/lib,usr/lib64}

if [[ ! -f "$KO" || ! -f "$BZ" ]]; then
  echo "missing kernel or module artifacts" >&2
  exit 1
fi

# Static busybox if present, else debootstrap shell
BB=""
for c in /bin/busybox /usr/bin/busybox; do
  [[ -x "$c" ]] && BB="$c" && break
done
if [[ -n "$BB" ]]; then
  cp "$BB" "$INITRD_DIR/bin/busybox"
  for a in sh mount cat dmesg poweroff insmod rmmod sleep; do
    ln -sf busybox "$INITRD_DIR/bin/$a"
  done
else
  echo "install busybox-static or run on system with busybox" >&2
  exit 2
fi

cp "$KO" "$INITRD_DIR/livepatch-cmdline.ko"

cat >"$INITRD_DIR/init" <<'INIT'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
echo "LP-PILOT-01 QEMU init"
echo "=== PRE_PATCH ==="
cat /proc/cmdline || true
insmod /livepatch-cmdline.ko
echo "INSMOD_RC=$?"
sleep 1
echo "=== POST_PATCH ==="
cat /proc/cmdline || true
if grep -q 'live patched' /proc/cmdline 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
echo 0 > /sys/kernel/livepatch/livepatch_cmdline/enabled 2>/dev/null || \
  echo 0 > /sys/kernel/livepatch/livepatch-cmdline/enabled 2>/dev/null || true
sleep 1
echo "=== POST_REVERT ==="
cat /proc/cmdline || true
if grep -q 'live patched' /proc/cmdline 2>/dev/null; then echo P3_PASS=0; else echo P3_PASS=1; fi
echo "=== DONE ==="
poweroff -f
INIT
chmod +x "$INITRD_DIR/init"

rm -f "$QEMU_DIR/initrd.cpio.gz"
(
  cd "$INITRD_DIR"
  find . -print0 | cpio --null -o --format=newc | gzip -9
) >"$QEMU_DIR/initrd.cpio.gz"

: >"$SERIAL"
timeout 90 qemu-system-x86_64 \
  -kernel "$BZ" \
  -initrd "$QEMU_DIR/initrd.cpio.gz" \
  -append "console=ttyS0 panic=1 nokaslr init=/init" \
  -m 1024 -smp 1 -nographic -no-reboot \
  -serial file:"$SERIAL" 2>"$RES/qemu-stderr.log" || true

cp "$SERIAL" "$VALID"
echo "--- validation summary ---" | tee -a "$VALID"
grep -E 'PRE_PATCH|POST_PATCH|POST_REVERT|P2_PASS|P3_PASS|INSMOD|DONE' "$SERIAL" | tee -a "$VALID" || true

if grep -q 'P2_PASS=1' "$SERIAL" && grep -q 'P3_PASS=1' "$SERIAL"; then
  echo "BEHAVIORAL_PASS" | tee -a "$VALID"
  exit 0
fi
echo "BEHAVIORAL_FAIL" | tee -a "$VALID"
exit 1
