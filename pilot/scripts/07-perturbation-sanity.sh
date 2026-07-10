#!/usr/bin/env bash
# Perturbation sanity: wrong target symbol must fail load (LP-PILOT-01).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
HB="$ROOT/pilot/handbuild/LP-PILOT-01"
RES="$ROOT/pilot/results"
BZ="$ROOT/pilot/build/bzImage"
Q="$ROOT/pilot/build/qemu"
OUT="$RES/perturbation-sanity.txt"
SERIAL="$RES/perturbation-serial.log"
KDIR="${WORK_ROOT}/linux"

# Build wrong-symbol variant in isolated directory
BAD_DIR="$HB/perturb-wrongsym"
rm -rf "$BAD_DIR"
mkdir -p "$BAD_DIR"
sed 's/cmdline_proc_show/cmdline_proc_show_BADSYM/' "$HB/livepatch-cmdline.c" > "$BAD_DIR/livepatch-cmdline-bad.c"
cat > "$BAD_DIR/Makefile" <<'MK'
obj-m += livepatch-cmdline-bad.o
all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules
MK
make -C "$BAD_DIR" -j"$(nproc)" KDIR="$KDIR"
BAD_KO="$BAD_DIR/livepatch-cmdline-bad.ko"

INIT="$Q/perturb-initrd"
rm -rf "$INIT"
mkdir -p "$INIT"/{bin,proc,sys,dev}
cp /bin/busybox "$INIT/bin/"
for a in sh mount cat poweroff insmod; do ln -sf busybox "$INIT/bin/$a"; done
cp "$BAD_KO" "$INIT/"
cat > "$INIT/init" <<'INIT'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "=== PERTURBATION wrong-symbol ==="
insmod /livepatch-cmdline-bad.ko 2>/tmp/e
echo "INSMOD_RC=$?"
cat /tmp/e 2>/dev/null || true
cat /proc/cmdline || true
if grep -q 'live patched' /proc/cmdline 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
poweroff -f
INIT
chmod +x "$INIT/init"
( cd "$INIT" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/perturb-initrd.cpio.gz"

: >"$SERIAL"
timeout 60 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/perturb-initrd.cpio.gz" \
  -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
  -serial file:"$SERIAL" 2>/dev/null || true

{
  echo "# Perturbation sanity — LP-PILOT-01"
  echo
  echo "**Method:** hand-built module with deliberately wrong \`old_name\` (symbol mismatch)."
  echo "**Expected:** insmod failure and P2_PASS=0 (no behavioral change)."
  echo
  grep -E 'PERTURBATION|INSMOD|P2_PASS|Error|error|not found' "$SERIAL" || cat "$SERIAL"
} | tee "$OUT"

if grep -q 'INSMOD_RC=0' "$SERIAL" && grep -q 'P2_PASS=1' "$SERIAL"; then
  echo "PERTURBATION_FAIL" | tee -a "$OUT"
  exit 1
fi
echo "PERTURBATION_PASS" | tee -a "$OUT"
