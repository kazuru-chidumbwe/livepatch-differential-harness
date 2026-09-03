#!/usr/bin/env bash
# Second-pin depth on existing v6.1.119 bzImage:
#   • C3 structural + good/perturb QEMU (mutant class replay)
#   • two INCLUDE PRE-gated contract packs (52577, 36904)
# Does not rebuild the kernel tree.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
unset CURDIR || true
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"

PIN_TAG="${SECOND_PIN_TAG:-v6.1.119}"
DP="${SECOND_PIN_LINUX:-/opt/atlas/livepatch-corpus/linux-second-pin}"
BZ="${SECOND_PIN_BZ:-$DP/arch/x86/boot/bzImage}"
BASE="$ROOT/pilot/results/LP-SECOND-PIN-$PIN_TAG"
OUT="$BASE/SECOND-PIN-DEPTH"
Q="$ROOT/pilot/build/qemu"
JOBS="${BUILD_JOBS:-$(nproc)}"
LOG="/opt/atlas/livepatch-corpus/second-pin-depth.log"
CASE_ENV="$ROOT/pilot/cases/LP-PILOT-02-version/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"

mkdir -p "$OUT" "$Q" /opt/atlas/livepatch-corpus
exec > >(tee -a "$LOG") 2>&1

echo "SECOND_PIN_DEPTH_START=$(date -u +%FT%TZ)"
echo "PIN_TAG=$PIN_TAG"
echo "LINUX=$DP"
test -d "$DP/.git"
test -f "$BZ"
echo "PIN_COMMIT=$(git -C "$DP" rev-parse HEAD)"
sha256sum "$BZ" | tee "$OUT/bzImage.sha256"

run_pre_gated_qemu() {
  local ko="$1" outdir="$2" marker="$3" proc_file="$4" tag="$5"
  mkdir -p "$outdir"
  : >"$outdir/predicate-transcript.txt"
  python3 "$ROOT/pilot/scripts/pre-revert-scan.py" "$ko" | tee "$outdir/pre-revert-scan.txt"
  local pre_class triggers modbase init p3_block serial
  pre_class=$(awk -F= '/^PRE_CLASS=/{print $2}' "$outdir/pre-revert-scan.txt")
  triggers=$(awk -F= '/^PRE_TRIGGER_SYMBOLS=/{print $2}' "$outdir/pre-revert-scan.txt" || true)
  echo "PRE_CLASS=$pre_class" | tee -a "$outdir/predicate-transcript.txt"
  cp -f "$ko" "$outdir/$(basename "$ko")"
  modbase=$(basename "$ko" .ko)
  init="$Q/initrd-b2-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep grep; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${modbase}.ko"
  if [ "$pre_class" = "SOUND" ]; then
    p3_block="$(emit_p3_hardened_revert "$marker" "$proc_file" 30)"
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
if grep -q '$marker' $proc_file 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
$p3_block
poweroff -f
INIT
  chmod +x "$init/init"
  check_init_no_klp_glob "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-b2-$tag.cpio.gz"
  serial="$outdir/predicate-serial.log"
  : >"$serial"
  timeout 180 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-b2-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|KLP_|P2_PASS|P3_|PRE_' "$serial" | tee -a "$outdir/predicate-transcript.txt" || true
}

echo "=== DEPTH INCLUDE CVE-2023-52577 ==="
HB77="$ROOT/pilot/handbuild/LP-CVE-2023-52577"
make -C "$HB77" clean KDIR="$DP" >/dev/null 2>&1 || true
make -C "$HB77" -j"$JOBS" KDIR="$DP"
run_pre_gated_qemu \
  "$HB77/livepatch-cve-2023-52577.ko" \
  "$OUT/LP-CVE-2023-52577" \
  "CVE-2023-52577-HARNESS-MARK" "/proc/version" "b2-52577"

echo "=== DEPTH INCLUDE CVE-2024-36904 ==="
HB04="$ROOT/pilot/handbuild/LP-CVE-2024-36904"
make -C "$HB04" clean KDIR="$DP" >/dev/null 2>&1 || true
make -C "$HB04" -j"$JOBS" KDIR="$DP"
run_pre_gated_qemu \
  "$HB04/livepatch-cve-2024-36904.ko" \
  "$OUT/LP-CVE-2024-36904" \
  "CVE-2024-36904-HARNESS-MARK" "/proc/version" "b2-36904"

echo "=== DEPTH C3 mutant class (structural + QEMU) ==="
HB3="$ROOT/pilot/handbuild/LP-CORPUS-03-seqputs"
RES3="$OUT/LP-CORPUS-03"
MOD=livepatch-corpus03
mkdir -p "$RES3"
make -C "$HB3" clean KDIR="$DP" >/dev/null 2>&1 || true
make -C "$HB3" -j"$JOBS" KDIR="$DP"
KO="$HB3/${MOD}.ko"
PERT="$HB3/${MOD}.seqputs-to-putc.ko"
python3 "$ROOT/pilot/scripts/perturb-plt32-redirect.py" "$KO" "$PERT" seq_puts seq_putc
{
  echo "# DEPTH C3 on $PIN_TAG"
  echo "## Structural binding oracle"
  python3 "$ROOT/pilot/scripts/verify-plt32-binding.py" --check-redirect \
    "$KO" "$PERT" seq_puts seq_putc
} | tee "$RES3/structural-bind.txt"
grep -q 'STRUCTURAL_BIND_PASS=1' "$RES3/structural-bind.txt"
cp -f "$KO" "$PERT" "$RES3/"

run_c3_qemu() {
  local ko="$1" tag="$2"
  local init="$Q/initrd-b2-c3-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/busybox"
  for a in sh mount cat poweroff insmod sleep dmesg grep; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${MOD}.ko"
  cat >"$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
(
  i=0
  while [ \$i -lt 30 ]; do
    for d in /sys/kernel/livepatch/*; do
      if [ -f "\$d/force" ] && [ -f "\$d/transition" ]; then
        tr=\$(cat "\$d/transition" 2>/dev/null || echo 0)
        if [ "\$tr" != "0" ]; then
          echo 1 >"\$d/force" 2>/dev/null || true
          echo "KLP_FORCE=1"
        fi
      fi
    done
    i=\$((i + 1))
    sleep 1
  done
) &
insmod /${MOD}.ko
echo INSMOD_RC=\$?
sleep 1
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
poweroff -f
INIT
  chmod +x "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-b2-c3-$tag.cpio.gz"
  local serial="$RES3/${tag}-serial.log"
  : >"$serial"
  timeout "${QEMU_TIMEOUT_SEC:-180}" qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-b2-c3-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|P2_PASS|KLP_FORCE' "$serial" || tail -20 "$serial"
}

{
  echo "=== GOOD (semantic P2 must PASS) ==="
  run_c3_qemu "$KO" good
  echo "=== PERTURB (INSMOD=0 + semantic P2 must FAIL) ==="
  run_c3_qemu "$PERT" perturb
} | tee "$RES3/predicate-transcript.txt"

# Summarize
{
  echo "HOST=$(hostname)"
  echo "PIN_TAG=$PIN_TAG"
  echo "PIN_COMMIT=$(git -C "$DP" rev-parse HEAD)"
  sha256sum "$BZ" | awk '{print "BZIMAGE_SHA256="$1}'
  echo "DEPTH_INCLUDE=CVE-2023-52577,CVE-2024-36904"
  echo "DEPTH_MUTANT=C3-seqputs-to-putc"
  echo "SECOND_PIN_DEPTH_DONE=$(date -u +%FT%TZ)"
} | tee "$OUT/DEPTH-SUMMARY.txt" | tee "$BASE/SECOND_PIN_DEPTH_COMPLETE.txt"

echo "SECOND_PIN_DEPTH_COMPLETE=1"
