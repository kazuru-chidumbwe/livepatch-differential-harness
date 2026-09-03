#!/usr/bin/env bash
#  v0.2.0 lab packs: PRE unit tests, PRE-gated Dirty Pipe (if pin tree exists),
# and two INCLUDE CVE contract micro-cases on v6.6.47.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
unset CURDIR || true
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
LINUX="${LINUX:-$WORK_ROOT/linux}"
BZ="${BZ:-$ROOT/pilot/build/bzImage}"
Q="$ROOT/pilot/build/qemu"
JOBS="${BUILD_JOBS:-$(nproc)}"
mkdir -p "$Q"

echo "_V020_HOST=$(hostname)"
echo "_V020_ROOT=$ROOT"
echo "_V020_LINUX=$LINUX"
echo "_V020_BZ=$BZ"

python3 "$ROOT/pilot/scripts/test_pre_revert_scan.py"

run_pre_gated_qemu() {
  local ko="$1" outdir="$2" marker="$3" proc_file="$4" tag="$5"
  mkdir -p "$outdir"
  local pre_log="$outdir/pre-revert-scan.txt"
  python3 "$ROOT/pilot/scripts/pre-revert-scan.py" "$ko" | tee "$pre_log"
  local pre_class
  pre_class=$(awk -F= '/^PRE_CLASS=/{print $2}' "$pre_log")
  local triggers
  triggers=$(awk -F= '/^PRE_TRIGGER_SYMBOLS=/{print $2}' "$pre_log" || true)
  echo "PRE_CLASS=$pre_class" | tee -a "$outdir/predicate-transcript.txt"
  cp -f "$ko" "$outdir/$(basename "$ko")"

  local modbase
  modbase=$(basename "$ko" .ko)
  local init="$Q/initrd-eisej-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep grep; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${modbase}.ko"
  local p3_block
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
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-eisej-$tag.cpio.gz"
  local serial="$outdir/predicate-serial.log"
  : >"$serial"
  timeout 180 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-eisej-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|KLP_|P2_PASS|P3_|PRE_' "$serial" | tee -a "$outdir/predicate-transcript.txt" || true
}

build_handbuild() {
  local subdir="$1"
  local hb="$ROOT/pilot/handbuild/$subdir"
  unset CURDIR || true
  make -C "$hb" clean KDIR="$LINUX" >/dev/null 2>&1 || true
  make -C "$hb" -j"$JOBS" KDIR="$LINUX"
}

# --- INCLUDE CVE micro-cases on v6.6.47 ---
if [ ! -f "$BZ" ]; then
  echo "FATAL: missing bzImage at $BZ" >&2
  exit 1
fi
if [ ! -d "$LINUX" ]; then
  echo "FATAL: missing kernel tree at $LINUX" >&2
  exit 1
fi

build_handbuild LP-CVE-2023-52577
run_pre_gated_qemu \
  "$ROOT/pilot/handbuild/LP-CVE-2023-52577/livepatch-cve-2023-52577.ko" \
  "$ROOT/pilot/results/LP-CVE-2023-52577" \
  "CVE-2023-52577-HARNESS-MARK" "/proc/version" "cve-2023-52577"

build_handbuild LP-CVE-2024-36904
run_pre_gated_qemu \
  "$ROOT/pilot/handbuild/LP-CVE-2024-36904/livepatch-cve-2024-36904.ko" \
  "$ROOT/pilot/results/LP-CVE-2024-36904" \
  "CVE-2024-36904-HARNESS-MARK" "/proc/version" "cve-2024-36904"

# --- Dirty Pipe PRE-gated re-run (v5.16.10 pin) if artifacts exist ---
DP_LINUX="${DIRTYPIPE_LINUX:-/opt/atlas/livepatch-corpus/linux-dirtypipe}"
DP_BZ="${DIRTYPIPE_BZ:-$DP_LINUX/arch/x86/boot/bzImage}"
DP_OUT="$ROOT/pilot/results/LP-CORPUS-DIRTYPIPE"
if [ -f "$DP_BZ" ] && [ -d "$DP_LINUX" ]; then
  echo "DIRTYPIPE_PIN_PRESENT=1"
  LINUX_SAVE="$LINUX"
  BZ_SAVE="$BZ"
  LINUX="$DP_LINUX"
  BZ="$DP_BZ"
  build_handbuild LP-CORPUS-DIRTYPIPE
  run_pre_gated_qemu \
    "$ROOT/pilot/handbuild/LP-CORPUS-DIRTYPIPE/livepatch-dirtypipe.ko" \
    "$DP_OUT" \
    "DIRTYPIPE-HARNESS-MARK" "/proc/version" "dirtypipe"
  LINUX="$LINUX_SAVE"
  BZ="$BZ_SAVE"
  echo "DIRTYPIPE_PRE_GATED=1" | tee "$DP_OUT/DIRTYPIPE_PRE_GATED"
else
  echo "DIRTYPIPE_PIN_PRESENT=0"
  mkdir -p "$DP_OUT"
  echo "DIRTYPIPE_SKIP=missing v5.16.10 tree or bzImage at $DP_LINUX" | tee "$DP_OUT/DIRTYPIPE_SKIP.txt"
fi

echo "_V020_DONE=1"
