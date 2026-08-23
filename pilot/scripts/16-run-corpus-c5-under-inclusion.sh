#!/usr/bin/env bash
# LP-CORPUS-05 — mechanism #2 under-inclusion probe (hot/cold inline scope).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CASE_ENV="$ROOT/pilot/cases/LP-CORPUS-05-inline/case.env"
# shellcheck source=/dev/null
source "$CASE_ENV"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"

HB="$ROOT/pilot/handbuild/$HANDUILD_SUBDIR"
RES="$ROOT/pilot/results/LP-CORPUS-05-under-inclusion"
BZ="$ROOT/pilot/build/bzImage"
Q="$ROOT/pilot/build/qemu"
LINUX="$WORK_ROOT/linux"
BASE_PATCH="$ROOT/pilot/patches/LP-CORPUS-05-inline-base.patch"
FIX_PATCH="$ROOT/pilot/patches/LP-CORPUS-05-inline-fix.patch"
mkdir -p "$RES"

need_base_kernel() {
  if ! grep -q lp_inline_probe_marker "$LINUX/fs/proc/version.c" 2>/dev/null; then
    echo "Applying LP-CORPUS-05-inline-base.patch to kernel tree..."
    ( cd "$LINUX" && patch -p1 -N ) <"$BASE_PATCH"
    echo "BASE_PATCH_APPLIED=1" | tee "$RES/kernel-base-patch.log"
    echo "Rebuild bzImage required (see lab-corpus-c5-run.py or pilot/scripts/03-build-kernel.sh)."
    return 1
  fi
  return 0
}

static_inline_analysis() {
  local tmp
  tmp=$(mktemp -d)
  cp "$LINUX/fs/proc/version.c" "$tmp/version.c"
  (
    cd "$tmp"
    gcc -I"$LINUX" -I"$LINUX/include" -I"$LINUX/arch/x86/include" \
      -I"$LINUX/arch/x86/include/generated" \
      -D__KERNEL__ -DKBUILD_MODNAME='"probe"' -c version.c -o version.o 2>"$RES/compile-version.o.log" || true
    if [ -f version.o ]; then
      objdump -d -M intel version.o | sed -n '/version_proc_show>/,/^$/p' >"$RES/disasm-hot-path.txt"
      objdump -d -M intel version.o | sed -n '/version_aux_proc_show>/,/^$/p' >"$RES/disasm-cold-path.txt"
      {
        echo "# Inlined lp_inline_probe_marker at both call sites (static analysis)"
        echo "## Hot: version_proc_show"
        grep -E 'call|seq_puts|INLINE' "$RES/disasm-hot-path.txt" || true
        echo
        echo "## Cold: version_aux_proc_show"
        grep -E 'call|seq_puts|INLINE' "$RES/disasm-cold-path.txt" || true
      } >"$RES/inline-callsite-analysis.txt"
    fi
  )
  rm -rf "$tmp"
}

klp_scope_report() {
  local ko="$1"
  {
    echo "# klp_func scope (replacement symbols in livepatch module)"
    readelf -s "$ko" | grep -E 'hb_version|klp|version_' || true
    echo
    echo "klp_funcs registered: version_proc_show ONLY (version_aux_proc_show not listed — intentional under-inclusion)"
  } >"$RES/klp-func-scope.txt"
}

run_qemu() {
  local ko="$1"
  local init="$Q/initrd-c5"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep dmesg; do ln -sf busybox "$init/bin/$a"; done
  cp "$ko" "$init/${MODULE_BASENAME}.ko"
  cat >"$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
dmesg -c >/dev/null
echo "=== PRE ==="
echo -n "HOT="; cat $PROC_FILE 2>/dev/null || echo MISSING
echo -n "COLD="; cat $PROC_FILE_COLD 2>/dev/null || echo MISSING
insmod /${MODULE_BASENAME}.ko
echo INSMOD_RC=\$?
sleep 1
echo "=== POST ==="
echo -n "HOT="; cat $PROC_FILE 2>/dev/null || echo MISSING
echo -n "COLD="; cat $PROC_FILE_COLD 2>/dev/null || echo MISSING
if grep -q '$MARKER_HOT' $PROC_FILE 2>/dev/null; then echo P2_HOT=1; else echo P2_HOT=0; fi
if grep -q '$MARKER_COLD_ORIG' $PROC_FILE_COLD 2>/dev/null; then echo P2_COLD_STILL_ORIG=1; else echo P2_COLD_STILL_ORIG=0; fi
if grep -q '$MARKER_HOT' $PROC_FILE 2>/dev/null && grep -q '$MARKER_COLD_ORIG' $PROC_FILE_COLD 2>/dev/null; then
  echo UNDER_INCLUSION_DETECTED=1
else
  echo UNDER_INCLUSION_DETECTED=0
fi
$(emit_p3_hardened_revert "$MARKER_HOT" "$PROC_FILE" 30)
poweroff -f
INIT
  chmod +x "$init/init"
  check_init_no_klp_glob "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-c5.cpio.gz"
  local serial="$RES/predicate-serial.log"
  : >"$serial"
  timeout 120 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-c5.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'PRE|POST|HOT=|COLD=|INSMOD|P2_|UNDER_|P3_|KLP_' "$serial" | tee "$RES/predicate-transcript.txt"
}

# --- main ---
need_base_kernel || static_inline_analysis

static_inline_analysis

make -C "$HB" clean KDIR="$LINUX" >/dev/null 2>&1 || true
make -C "$HB" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$LINUX" >"$RES/handbuild.log" 2>&1
KO="$HB/livepatch-inline.ko"
[ -f "$KO" ] || { tail -20 "$RES/handbuild.log"; exit 1; }
cp "$KO" "$RES/livepatch-underincl.ko"
klp_scope_report "$KO"

if [ -f "$BZ" ] && grep -q version_aux_proc_show "$LINUX/fs/proc/version.c" 2>/dev/null; then
  if zcat /proc/config.gz 2>/dev/null | grep -q version_aux || true; then :; fi
  run_qemu "$KO"
else
  echo "QEMU_SKIPPED=1 (rebuild bzImage with base patch for /proc/version_aux)" | tee -a "$RES/predicate-transcript.txt"
fi

# kpatch changed-function report (fix patch semantics)
if command -v kpatch-build >/dev/null 2>&1 && [ -f "$FIX_PATCH" ]; then
  {
    echo "# kpatch-build on LP-CORPUS-05-inline-fix.patch"
    echo "(requires base kernel tree already containing inline probe)"
  } >"$RES/kpatch-build.log"
  # Document-only unless tree is prepared
  echo "kpatch-build deferred to lab-corpus-c5-run.py full pipeline" >>"$RES/kpatch-build.log"
fi

echo C5_UNDER_INCLUSION_DONE
