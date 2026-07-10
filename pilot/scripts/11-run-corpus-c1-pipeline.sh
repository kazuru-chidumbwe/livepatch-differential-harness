#!/usr/bin/env bash
# LP-CORPUS-01 / B1: kpatch-build vs hand-build klp reference on PILOT-02 fix.
# Paper label: B1 (not blocked C1 = klp-build-upstream vs kpatch on 6.19+).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"

RES="$ROOT/pilot/results/LP-CORPUS-01-pipeline"
PATCH="$ROOT/pilot/patches/LP-PILOT-02-version.patch"
HB="$ROOT/pilot/handbuild/LP-PILOT-02"
KDIR="$WORK_ROOT/linux"
mkdir -p "$RES"

{
  echo "# LP-CORPUS-01 pipeline comparison — PILOT-02 fix"
  echo
  echo "## Pins"
  echo "KERNEL_TAG=$KERNEL_TAG"
  echo "KERNEL_COMMIT=$KERNEL_COMMIT"
  echo "HOST_KERNEL=$(uname -r)"
  echo "GCC=$(gcc --version | head -1)"
  echo
  echo "## Kernel config"
  grep -E 'CONFIG_LIVEPATCH|CONFIG_KPATCH' "$KDIR/.config" || true
  echo
} | tee "$RES/manifest.txt"

# klp reference (hand-build ground truth on v6.6.47 — klp-build-upstream requires 6.19+)
make -C "$HB" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$KDIR" 2>&1 | tail -5 | tee -a "$RES/manifest.txt"
KLP_KO="$HB/livepatch-version.ko"
cp "$KLP_KO" "$RES/klp-handbuild-reference.ko"
readelf -rW "$KLP_KO" | awk '/\.rela\.text/,/^$/' >"$RES/klp-relocations.txt"

# kpatch-build attempt
if command -v kpatch-build >/dev/null 2>&1; then
  echo "## kpatch-build" | tee -a "$RES/manifest.txt"
  set +e
  kpatch-build -v "$KERNEL_TAG" "$PATCH" 2>&1 | tee "$RES/kpatch-build.log"
  krc=$?
  set -e
  echo "KPATCH_BUILD_RC=$krc" | tee -a "$RES/manifest.txt"
  find /tmp -maxdepth 3 -name '*.ko' -newer "$PATCH" 2>/dev/null | head -5 >>"$RES/manifest.txt" || true
else
  echo "KPATCH_BUILD_RC=not_installed" | tee -a "$RES/manifest.txt"
  echo "Install dynup/kpatch on lab; kernel also needs CONFIG_KPATCH=y for load." >>"$RES/manifest.txt"
fi

if [ -f "$RES/klp-handbuild-reference.ko" ] && [ -f "$RES/kpatch-output.ko" ]; then
  diff -u "$RES/klp-relocations.txt" <(readelf -rW "$RES/kpatch-output.ko" | awk '/\.rela\.text/,/^$/') \
    >"$RES/relocation-diff.txt" || true
fi

objdump -d -M intel "$KLP_KO" | sed -n '/<hb_version_proc_show>:/,/^$/p' | head -50 >"$RES/disasm-klp-handbuild.txt"
echo "LP-CORPUS-01-DONE"
