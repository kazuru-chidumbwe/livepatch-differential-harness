#!/usr/bin/env bash
# PRE-gated Dirty Pipe QEMU only (v5.16.10 pin). Assumes bzImage already built.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
unset CURDIR || true
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"
DP="${DIRTYPIPE_LINUX:-/opt/atlas/livepatch-corpus/linux-dirtypipe}"
BZ="${DIRTYPIPE_BZ:-$DP/arch/x86/boot/bzImage}"
HB="$ROOT/pilot/handbuild/LP-CORPUS-DIRTYPIPE"
OUT="$ROOT/pilot/results/LP-CORPUS-DIRTYPIPE"
Q="$ROOT/pilot/build/qemu"
MARKER="DIRTYPIPE-HARNESS-MARK"
PROC_FILE="/proc/version"
JOBS="$(nproc)"
mkdir -p "$OUT" "$Q"
if [ ! -f "$BZ" ]; then
  echo "FATAL: missing $BZ" >&2
  exit 1
fi
make -C "$DP" -j"$JOBS" modules_prepare
make -C "$HB" clean KDIR="$DP" >/dev/null 2>&1 || true
make -C "$HB" -j"$JOBS" KDIR="$DP"
KO="$HB/livepatch-dirtypipe.ko"
test -f "$KO"
python3 "$ROOT/pilot/scripts/pre-revert-scan.py" "$KO" | tee "$OUT/pre-revert-scan.txt"
pre_class=$(awk -F= '/^PRE_CLASS=/{print $2}' "$OUT/pre-revert-scan.txt")
triggers=$(awk -F= '/^PRE_TRIGGER_SYMBOLS=/{print $2}' "$OUT/pre-revert-scan.txt" || true)
: >"$OUT/predicate-transcript.txt"
echo "PRE_CLASS=$pre_class" | tee -a "$OUT/predicate-transcript.txt"
cp -f "$KO" "$OUT/livepatch-dirtypipe.ko"
modbase=$(basename "$KO" .ko)
init="$Q/initrd-eisej-dirtypipe"
rm -rf "$init"
mkdir -p "$init"/{bin,proc,sys,dev}
cp /bin/busybox "$init/bin/"
for a in sh mount cat poweroff insmod sleep grep; do ln -sf busybox "$init/bin/$a"; done
cp "$KO" "$init/${modbase}.ko"
if [ "$pre_class" = "SOUND" ]; then
  p3_block="$(emit_p3_hardened_revert "$MARKER" "$PROC_FILE" 30)"
else
  p3_block="$(emit_pre_skip_p3 "${pre_class:-OUT_OF_SCOPE}" "${triggers:-}")"
fi
cat >"$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
insmod /${modbase}.ko
echo INSMOD_RC=\$?
sleep 1
$(emit_klp_post_load_status)
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
$p3_block
poweroff -f
INIT
chmod +x "$init/init"
check_init_no_klp_glob "$init/init"
( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-eisej-dirtypipe.cpio.gz"
serial="$OUT/predicate-serial-pregated.log"
: >"$serial"
timeout 180 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-eisej-dirtypipe.cpio.gz" \
  -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
  -serial file:"$serial" 2>/dev/null || true
grep -E 'INSMOD|KLP_|P2_PASS|P3_|PRE_' "$serial" | tee -a "$OUT/predicate-transcript.txt" || true
{
  echo "HOST=$(hostname)"
  echo "KERNEL_TAG=v5.16.10"
  echo "BZIMAGE=$BZ"
  sha256sum "$BZ" | awk '{print "BZIMAGE_SHA256="$1}'
  echo "PRE_CLASS=$pre_class"
  echo "PRE_GATED=1"
} | tee "$OUT/pin-pregated.txt"
echo DIRTYPIPE_PRE_GATED_DONE
