#!/usr/bin/env bash
# C6 — kpatch-build benign variation: PILOT-02 fix at -O2 and -Os.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/pilot/results/LP-CORPUS-06-kpatch-opt"
PATCH="$ROOT/pilot/patches/LP-PILOT-02-version.patch"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
LINUX="$WORK_ROOT/linux"
VMLINUX="$LINUX/vmlinux"
BZ="$ROOT/pilot/build/bzImage"
Q="$ROOT/pilot/build/qemu"
mkdir -p "$OUT"

run_pred() {
  local ko="$1" tag="$2"
  local modbase
  modbase=$(basename "$ko" .ko)
  local init="$Q/initrd-c6-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${modbase}.ko"
  cat >"$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
insmod /${modbase}.ko
echo INSMOD_RC=\$?
sleep 1
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
echo 0 > /sys/kernel/livepatch/*/enabled 2>/dev/null || true
sleep 1
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P3_PASS=0; else echo P3_PASS=1; fi
poweroff -f
INIT
  chmod +x "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-c6-$tag.cpio.gz"
  local serial="$OUT/predicate-$tag-serial.log"
  : >"$serial"
  timeout 90 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-c6-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|P2_PASS|P3_PASS' "$serial" || true
}

for opt in O2 Os; do
  flags="-O2"; [ "$opt" = "Os" ] && flags="-Os"
  log="$OUT/kpatch-build-$opt.log"
  echo "=== kpatch-build EXTRA_CFLAGS=$flags ===" | tee "$log"
  if KPATCH_CFLAGS="$flags" kpatch-build -s "$LINUX" -v "$VMLINUX" "$PATCH" >>"$log" 2>&1; then
    echo "KPATCH_BUILD_RC=0" | tee -a "$log"
    ko=$(find /tmp/kpatch-out -name 'livepatch-LP-PILOT-02-version.ko' 2>/dev/null | head -1)
    [ -n "$ko" ] && cp "$ko" "$OUT/kpatch-output-$opt.ko"
    run_pred "$OUT/kpatch-output-$opt.ko" "$opt" | tee -a "$OUT/predicate-transcript.txt"
  else
    echo "KPATCH_BUILD_RC=$?" | tee -a "$log"
  fi
done

echo C6_KPATCH_OPT_DONE
