#!/usr/bin/env bash
# B1 predicates: hand-build klp vs kpatch-build on PILOT-02 fix (dir: LP-CORPUS-01-pipeline).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"
OUT="$ROOT/pilot/results/LP-CORPUS-01-pipeline"
BZ="$ROOT/pilot/build/bzImage"
KLP="$OUT/klp-handbuild-reference.ko"
KP="$OUT/kpatch-output.ko"
MARKER='LP-PILOT-02 patched-by-harness'
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"

run_pred() {
  local ko="$1" tag="$2"
  local modbase
  modbase=$(basename "$ko" .ko)
  local init="$ROOT/pilot/build/qemu/initrd-c1-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep dmesg; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${modbase}.ko"
  cat > "$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
dmesg -c >/dev/null
echo "=== C1_${tag} ==="
insmod /${modbase}.ko
echo "INSMOD_RC=\$?"
sleep 1
$(emit_klp_post_load_status)
dmesg | tail -25
echo "---PROC---"
cat $PROC_FILE || echo PROC_FAIL
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
$(emit_p3_hardened_revert "$MARKER" "$PROC_FILE" 30)
poweroff -f
INIT
  chmod +x "$init/init"
  check_init_no_klp_glob "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$ROOT/pilot/build/qemu/initrd-c1-$tag.cpio.gz"
  local serial="$OUT/predicate-$tag-serial.log"
  : >"$serial"
  timeout 120 qemu-system-x86_64 -kernel "$BZ" -initrd "$ROOT/pilot/build/qemu/initrd-c1-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
}

[ -f "$KLP" ] || { echo "missing $KLP"; exit 1; }
[ -f "$KP" ] || { echo "missing $KP"; exit 1; }

# disasm for patch function
objdump -d -M intel "$KLP" | sed -n '/hb_version_proc_show>/,/^$/p' | head -40 >"$OUT/disasm-klp-handbuild.txt"
objdump -d -M intel "$KP" | sed -n '/version_proc_show>/,/^$/p' | head -50 >"$OUT/disasm-kpatch.txt"
diff -u "$OUT/disasm-klp-handbuild.txt" "$OUT/disasm-kpatch.txt" >"$OUT/disassembly-diff.txt" || true

run_pred "$KLP" klp
run_pred "$KP" kpatch

{
  echo "# B1 pipeline baseline predicate transcript (hand-build klp vs kpatch-build)"
  echo
  echo "## klp hand-build"
  grep -E 'C1_|INSMOD|KLP_|P2_PASS|P3_|livepatch|#PF|PROC|---' "$OUT/predicate-klp-serial.log" || tail -35 "$OUT/predicate-klp-serial.log"
  echo
  echo "## kpatch-build"
  grep -E 'C1_|INSMOD|KLP_|P2_PASS|P3_|livepatch|#PF|PROC|---' "$OUT/predicate-kpatch-serial.log" || tail -35 "$OUT/predicate-kpatch-serial.log"
} | tee "$OUT/predicate-transcript.txt"

echo C1_PREDICATES_DONE
