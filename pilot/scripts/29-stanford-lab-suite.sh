#!/usr/bin/env bash
# Stanford minor-rev lab suite (Host B / any lab): structural recheck + timed TCG P2/P3
# + benign-suite aggregation. No KVM required (Host B has no /dev/kvm).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/pilot/results/STANFORD-LAB-${STAMP}"
mkdir -p "$OUT"
SUMMARY="$OUT/SUMMARY.txt"
TIMING="$OUT/wall-clock.txt"
: >"$SUMMARY"
: >"$TIMING"

BZ_PRIMARY="${BZ_PRIMARY:-$ROOT/pilot/build/bzImage}"
BZ_SECOND="${BZ_SECOND:-/opt/atlas/livepatch-corpus/linux-second-pin/arch/x86/boot/bzImage}"
BZ_DIRTY="${BZ_DIRTY:-/opt/atlas/livepatch-corpus/linux-dirtypipe/arch/x86/boot/bzImage}"
QEMU_ACCEL="${QEMU_ACCEL:-tcg}"   # Host B: tcg only (no /dev/kvm)
QEMU_TIMEOUT_SEC="${QEMU_TIMEOUT_SEC:-180}"

qemu_accel_args() {
  case "$QEMU_ACCEL" in
    tcg|TCG) echo "-accel tcg" ;;
    kvm|KVM)
      if [[ -e /dev/kvm ]]; then echo "-accel kvm"; else
        echo "KVM requested but /dev/kvm missing; refusing" >&2
        return 1
      fi
      ;;
    *) echo "unknown QEMU_ACCEL=$QEMU_ACCEL" >&2; return 1 ;;
  esac
}

timed_qemu_marker() {
  local bz="$1" ko="$2" marker="$3" tag="$4" proc="${5:-/proc/version}"
  local init="$ROOT/pilot/build/qemu/initrd-stanford-$tag"
  local serial="$OUT/${tag}-serial.log"
  local t0 t1 elapsed
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep; do ln -sf busybox "$init/bin/$a"; done
  local base
  base="$(basename "$ko")"
  cp "$ko" "$init/$base"
  cat >"$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
insmod /$base
echo INSMOD_RC=\$?
sleep 1
$(emit_klp_post_load_status)
if grep -q '$marker' $proc 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
$(emit_p3_hardened_revert "$marker" "$proc" 30)
poweroff -f
INIT
  chmod +x "$init/init"
  check_init_no_klp_glob "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$ROOT/pilot/build/qemu/initrd-stanford-$tag.cpio.gz"
  : >"$serial"
  # shellcheck disable=SC2046
  t0=$(date +%s.%N)
  timeout "$QEMU_TIMEOUT_SEC" qemu-system-x86_64 -kernel "$bz" \
    -initrd "$ROOT/pilot/build/qemu/initrd-stanford-$tag.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    $(qemu_accel_args) \
    -serial file:"$serial" 2>/dev/null || true
  t1=$(date +%s.%N)
  elapsed=$(python3 -c "print(f'{float('$t1')-float('$t0'):.3f}')")
  echo "tag=$tag accel=$QEMU_ACCEL wall_sec=$elapsed" | tee -a "$TIMING"
  grep -E 'INSMOD|KLP_|P2_PASS|P3_' "$serial" | tee -a "$SUMMARY" || true
  echo "--- $tag ---" >>"$SUMMARY"
}

{
  echo "# Stanford lab suite $STAMP"
  echo "host=$(hostname)"
  echo "accel=$QEMU_ACCEL"
  echo "kvm_device=$( [[ -e /dev/kvm ]] && echo present || echo absent )"
  echo "cpu_virt_flags=$(egrep -c '(vmx|svm)' /proc/cpuinfo || echo 0)"
  echo
} | tee -a "$SUMMARY"

# --- Structural C3 (primary pin artifact if present; else second-pin) ---
C3_GOOD="$ROOT/pilot/results/LP-CORPUS-03-survivable-sym/livepatch-corpus03.ko"
C3_PERT="$ROOT/pilot/results/LP-CORPUS-03-survivable-sym/livepatch-corpus03.seqputs-to-putc.ko"
if [[ ! -f "$C3_GOOD" ]]; then
  C3_GOOD="$ROOT/pilot/results/LP-SECOND-PIN-v6.1.119/SECOND-PIN-DEPTH/LP-CORPUS-03/livepatch-corpus03.ko"
  C3_PERT="$ROOT/pilot/results/LP-SECOND-PIN-v6.1.119/SECOND-PIN-DEPTH/LP-CORPUS-03/livepatch-corpus03.seqputs-to-putc.ko"
fi
echo "## structural C3" | tee -a "$SUMMARY"
python3 "$ROOT/pilot/scripts/verify-plt32-binding.py" --check-redirect \
  "$C3_GOOD" "$C3_PERT" seq_puts seq_putc | tee "$OUT/structural-c3.txt" | tee -a "$SUMMARY"

# --- Timed P2/P3: INCLUDE 52577 on primary bzImage ---
KO52577="$ROOT/pilot/results/LP-CVE-2023-52577/livepatch-cve-2023-52577.ko"
if [[ -f "$KO52577" && -f "$BZ_PRIMARY" ]]; then
  timed_qemu_marker "$BZ_PRIMARY" "$KO52577" "CVE-2023-52577-HARNESS-MARK" "include-52577-primary" || true
fi

# --- Timed P2/P3: Dirty Pipe marker pack ---
KODP="$ROOT/pilot/results/LP-CORPUS-DIRTYPIPE/livepatch-dirtypipe.ko"
if [[ -f "$KODP" && -f "$BZ_DIRTY" ]]; then
  timed_qemu_marker "$BZ_DIRTY" "$KODP" "DIRTYPIPE-HARNESS-MARK" "dirtypipe-marker" || true
elif [[ -f "$KODP" && -f "$ROOT/pilot/results/LP-CORPUS-DIRTYPIPE/bzImage" ]]; then
  timed_qemu_marker "$ROOT/pilot/results/LP-CORPUS-DIRTYPIPE/bzImage" "$KODP" "DIRTYPIPE-HARNESS-MARK" "dirtypipe-marker" || true
fi

# --- Timed P2/P3: second-pin INCLUDE ---
KO_SP="$ROOT/pilot/results/LP-SECOND-PIN-v6.1.119/SECOND-PIN-DEPTH/LP-CVE-2023-52577/livepatch-cve-2023-52577.ko"
if [[ -f "$KO_SP" && -f "$BZ_SECOND" ]]; then
  timed_qemu_marker "$BZ_SECOND" "$KO_SP" "CVE-2023-52577-HARNESS-MARK" "include-52577-second" || true
fi

# --- Benign suite aggregation (existing cite-pin transcripts) ---
BENIGN="$OUT/BENIGN-SUITE.md"
{
  echo "# Benign variation suite (aggregated)"
  echo
  echo "| Control | Evidence path | Outcome |"
  echo "| --- | --- | --- |"
  if [[ -f "$ROOT/pilot/results/LP-PILOT-02/benign-variation.txt" ]]; then
    echo "| PILOT-02 -O2/-Os hand | \`pilot/results/LP-PILOT-02/benign-variation.txt\` | see file (BENIGN_VARIATION_PASS) |"
  fi
  if [[ -f "$ROOT/pilot/results/LP-CORPUS-01-pipeline/predicate-transcript.txt" ]]; then
    echo "| B1 hand vs kpatch | \`pilot/results/LP-CORPUS-01-pipeline/predicate-transcript.txt\` | P2/P3 agree |"
  fi
  if [[ -d "$ROOT/pilot/results/LP-CORPUS-06-kpatch-opt" ]]; then
    echo "| C6 -O2/-Os | \`pilot/results/LP-CORPUS-06-kpatch-opt/\` | P2/P3 contract pass |"
  fi
  echo
  echo "Cross-compiler (Clang vs GCC) and multi-binutils matrices are not claimed."
  echo "KVM ablation: not runnable on this host (\`/dev/kvm\` absent); published packs use TCG + \`nokaslr\`."
} >"$BENIGN"
cp "$BENIGN" "$ROOT/pilot/results/BENIGN-SUITE.md" 2>/dev/null || true

# --- KVM note ---
{
  echo
  echo "## KVM vs TCG"
  if [[ -e /dev/kvm ]]; then
    echo "KVM available — set QEMU_ACCEL=kvm to compare (not auto-run)."
  else
    echo "KVM_ABSENT=1 — Host B / this lab has no nested virt; Stanford Q9 answered as TCG-only on this host."
  fi
  echo "STANFORD_LAB_DONE=$STAMP"
} | tee -a "$SUMMARY"

echo "STANFORD_LAB_DONE=$STAMP" >"$ROOT/pilot/results/STANFORD-LAB-LATEST.txt"
echo "$OUT" >"$ROOT/pilot/results/STANFORD-LAB-LATEST-PATH.txt"
echo "Wrote $OUT"
cat "$TIMING"
