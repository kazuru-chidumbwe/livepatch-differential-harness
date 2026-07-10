#!/usr/bin/env bash
# Benign-variation resistance: rebuild LP-PILOT-02 under two codegen configs; P2/P3 must pass.
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

run_predicate_qemu() {
  local ko="$1" tag="$2"
  local init="$Q/initrd-bv-$tag"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${MODULE_BASENAME}.ko"
  cat > "$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
insmod /${MODULE_BASENAME}.ko
echo INSMOD_RC=\$?
sleep 1
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
echo 0 > /sys/kernel/livepatch/${SYSFS_NAME}/enabled 2>/dev/null || true
sleep 1
if grep -q '$MARKER' $PROC_FILE 2>/dev/null; then echo P3_PASS=0; else echo P3_PASS=1; fi
poweroff -f
INIT
  chmod +x "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) > "$Q/initrd-bv-$tag.cpio.gz"
  local serial="$RES/benign-variation-$tag-serial.log"
  : >"$serial"
  timeout 60 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-bv-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|P2_PASS|P3_PASS' "$serial" || cat "$serial"
}

build_handbuild() {
  local extra="$1" tag="$2"
  local outko="$HB/${MODULE_BASENAME}.${tag}.ko"
  make -C "$HB" clean KDIR="$WORK_ROOT/linux" >/dev/null 2>&1 || true
  make -C "$HB" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$WORK_ROOT/linux" EXTRA_CFLAGS="$extra" \
    >"$RES/benign-variation-build-$tag.log" 2>&1
  cp "$HB/${MODULE_BASENAME}.ko" "$outko"
  readelf -r "$outko" | grep -E 'R_X86_64_32S|R_X86_64_PLT32' | head -20 \
    >"$RES/benign-variation-reloc-$tag.txt"
  echo "$outko"
}

{
  echo "# LP-PILOT-02 benign-variation resistance"
  echo
  echo "Claim: behavioral predicates (P2/P3) pass despite different codegen (not overfitted to one .ko)."
  echo
} >"$RES/benign-variation.txt"

for spec in "O2:-O2" "Os:-Os"; do
  tag="${spec%%:*}"
  flags="${spec##*:}"
  echo "--- hand-build EXTRA_CFLAGS=$flags ($tag) ---"
  ko=$(build_handbuild "$flags" "$tag")
  echo "built: $ko"
  run_predicate_qemu "$ko" "$tag" | tee -a "$RES/benign-variation.txt"
  echo >>"$RES/benign-variation.txt"
done

# Optional kpatch-build path when installed (same source semantics, different pipeline)
if command -v kpatch-build >/dev/null 2>&1 && [ -f "$ROOT/pilot/patches/LP-PILOT-02-version.patch" ]; then
  echo "--- kpatch-build (if patch applies) ---" | tee -a "$RES/benign-variation.txt"
  for spec in "O2" "Os"; do
    flags="-O2"; [ "$spec" = "Os" ] && flags="-Os"
  # kpatch-build owns its own tree; document attempt only
    echo "kpatch-build EXTRA_CFLAGS=$flags — see build logs in corpus phase" | tee -a "$RES/benign-variation.txt"
  done
else
  echo "kpatch-build: not run (tool or pilot/patches/LP-PILOT-02-version.patch missing); hand-build flag sweep is primary." \
    >>"$RES/benign-variation.txt"
fi

pass=0
grep -q 'P2_PASS=1' "$RES/benign-variation-O2-serial.log" && \
grep -q 'P3_PASS=1' "$RES/benign-variation-O2-serial.log" && \
grep -q 'P2_PASS=1' "$RES/benign-variation-Os-serial.log" && \
grep -q 'P3_PASS=1' "$RES/benign-variation-Os-serial.log" && pass=1

echo "BENIGN_VARIATION_PASS=$pass"
[ "$pass" -eq 1 ]
