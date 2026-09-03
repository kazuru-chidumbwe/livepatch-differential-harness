#!/usr/bin/env bash
# INCLUDE packs — all six INCLUDE CVE contract packs on primary pin (v6.6.47).
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
LOG="$ROOT/pilot/results/INCLUDE-PACKS.log"
exec > >(tee -a "$LOG") 2>&1

echo "INCLUDE_PACKS_START=$(date -u +%FT%TZ)"
test -f "$BZ"
test -d "$LINUX"

run_pre_gated_qemu() {
  local ko="$1" outdir="$2" marker="$3" proc_file="$4" tag="$5"
  mkdir -p "$outdir"
  : >"$outdir/predicate-transcript.txt"
  python3 "$ROOT/pilot/scripts/pre-revert-scan.py" "$ko" | tee "$outdir/pre-revert-scan.txt"
  local pre_class triggers
  pre_class=$(awk -F= '/^PRE_CLASS=/{print $2}' "$outdir/pre-revert-scan.txt")
  triggers=$(awk -F= '/^PRE_TRIGGER_SYMBOLS=/{print $2}' "$outdir/pre-revert-scan.txt" || true)
  echo "PRE_CLASS=$pre_class" | tee -a "$outdir/predicate-transcript.txt"
  cp -f "$ko" "$outdir/$(basename "$ko")"
  local modbase init p3_block serial
  modbase=$(basename "$ko" .ko)
  init="$Q/initrd-livepatch-$tag"
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
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-livepatch-$tag.cpio.gz"
  serial="$outdir/predicate-serial.log"
  : >"$serial"
  timeout 180 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-livepatch-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|KLP_|P2_PASS|P3_|PRE_' "$serial" | tee -a "$outdir/predicate-transcript.txt" || true
}

build_one() {
  local subdir="$1" cve="$2" tag="$3"
  local hb="$ROOT/pilot/handbuild/$subdir"
  local slug="${cve,,}"
  make -C "$hb" clean KDIR="$LINUX" >/dev/null 2>&1 || true
  make -C "$hb" -j"$JOBS" KDIR="$LINUX"
  run_pre_gated_qemu \
    "$hb/livepatch-${slug}.ko" \
    "$ROOT/pilot/results/$subdir" \
    "${cve}-HARNESS-MARK" "/proc/version" "$tag"
}

# Ensure packs exist
python3 "$ROOT/pilot/scripts/gen_include_contract_packs.py"

build_one LP-CVE-2023-52577 CVE-2023-52577 cve-2023-52577
build_one LP-CVE-2023-52578 CVE-2023-52578 cve-2023-52578
build_one LP-CVE-2024-36904 CVE-2024-36904 cve-2024-36904
build_one LP-CVE-2024-27395 CVE-2024-27395 cve-2024-27395
build_one LP-CVE-2024-22705 CVE-2024-22705 cve-2024-22705
build_one LP-CVE-2024-35864 CVE-2024-35864 cve-2024-35864

{
  echo "INCLUDE_PACKS_DONE=$(date -u +%FT%TZ)"
  echo "INCLUDE_N=6"
} | tee "$ROOT/pilot/results/INCLUDE-PACKS-DONE.txt"
echo "INCLUDE_PACKS_COMPLETE=1"
