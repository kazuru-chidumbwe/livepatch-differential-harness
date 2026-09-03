#!/usr/bin/env bash
# second-pin smoke — second LTS pin (v6.1.119): bzImage + one PRE-gated contract smoke.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
unset CURDIR || true
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"
PIN_TAG="${SECOND_PIN_TAG:-v6.1.119}"
DP="/opt/atlas/livepatch-corpus/linux-second-pin"
LOG="/opt/atlas/livepatch-corpus/second-pin-build.log"
JOBS="${BUILD_JOBS:-$(nproc)}"
OUT="$ROOT/pilot/results/LP-SECOND-PIN-$PIN_TAG"
HB="$ROOT/pilot/handbuild/LP-CVE-2023-52577"
Q="$ROOT/pilot/build/qemu"
mkdir -p /opt/atlas/livepatch-corpus "$OUT" "$Q"

{
  echo "SECOND_PIN_SMOKE_START=$(date -u +%FT%TZ)"
  echo "PIN_TAG=$PIN_TAG"
  sudo mkdir -p /opt/atlas/livepatch-corpus
  sudo chown -R "$(id -un):$(id -gn)" /opt/atlas/livepatch-corpus || true
  if [ ! -d "$DP/.git" ]; then
    rm -rf "$DP"
    git clone --depth 1 --branch "$PIN_TAG" \
      https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$DP"
  fi
  cd "$DP"
  echo "PIN_COMMIT=$(git rev-parse HEAD)"
  make defconfig
  append_cfg() {
    local key=$1 val=$2
    if grep -q "^${key}=" .config; then
      sed -i "s/^${key}=.*/${key}=${val}/" .config
    else
      echo "${key}=${val}" >> .config
    fi
  }
  append_cfg CONFIG_LIVEPATCH y
  append_cfg CONFIG_MODULE_UNLOAD y
  append_cfg CONFIG_KALLSYMS_ALL y
  append_cfg CONFIG_DEBUG_INFO y
  append_cfg CONFIG_FUNCTION_TRACER y
  append_cfg CONFIG_FTRACE y
  append_cfg CONFIG_KPROBES y
  append_cfg CONFIG_MODULES y
  append_cfg CONFIG_MODULE_SIG n
  make olddefconfig
  # gcc-13+ objtool xrealloc workaround (same class as Dirty Pipe)
  python3 - <<'PY'
from pathlib import Path
p = Path("tools/lib/subcmd/subcmd-util.h")
if not p.is_file():
    raise SystemExit(0)
t = p.read_text()
old = """static inline void *xrealloc(void *ptr, size_t size)
{
	void *ret = realloc(ptr, size);
	if (!ret && !size)
		ret = realloc(ptr, 1);
	if (!ret) {
		ret = realloc(ptr, size);
		if (!ret && !size)
			ret = realloc(ptr, 1);
		if (!ret)
			die("Out of memory, realloc failed");
	}
	return ret;
}
"""
new = """static inline void *xrealloc(void *ptr, size_t size)
{
	void *nptr = realloc(ptr, size);
	if (!nptr && !size)
		nptr = realloc(NULL, 1);
	if (!nptr)
		die("Out of memory, realloc failed");
	return nptr;
}
"""
if "void *nptr = realloc" in t:
    print("XREALLOC_ALREADY_PATCHED")
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print("PATCHED_XREALLOC")
else:
    print("XREALLOC_BLOCK_NOT_FOUND")
PY
  make -j"$JOBS" bzImage modules_prepare
  echo "SECOND_PIN_BUILD_OK=$(date -u +%FT%TZ)"
  BZ="$DP/arch/x86/boot/bzImage"
  sha256sum "$BZ" | tee "$OUT/bzImage.sha256"
  make -C "$HB" clean KDIR="$DP" >/dev/null 2>&1 || true
  make -C "$HB" -j"$JOBS" KDIR="$DP"
  KO="$HB/livepatch-cve-2023-52577.ko"
  python3 "$ROOT/pilot/scripts/pre-revert-scan.py" "$KO" | tee "$OUT/pre-revert-scan.txt"
  pre_class=$(awk -F= '/^PRE_CLASS=/{print $2}' "$OUT/pre-revert-scan.txt")
  triggers=$(awk -F= '/^PRE_TRIGGER_SYMBOLS=/{print $2}' "$OUT/pre-revert-scan.txt" || true)
  : >"$OUT/predicate-transcript.txt"
  echo "PRE_CLASS=$pre_class" | tee -a "$OUT/predicate-transcript.txt"
  cp -f "$KO" "$OUT/"
  modbase=$(basename "$KO" .ko)
  init="$Q/initrd-second-pin"
  rm -rf "$init"
  mkdir -p "$init"/{bin,proc,sys,dev}
  cp /bin/busybox "$init/bin/"
  for a in sh mount cat poweroff insmod sleep grep; do ln -sf busybox "$init/bin/$a"; done
  cp "$KO" "$init/${modbase}.ko"
  MARKER="CVE-2023-52577-HARNESS-MARK"
  if [ "$pre_class" = "SOUND" ]; then
    p3_block="$(emit_p3_hardened_revert "$MARKER" "/proc/version" 30)"
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
if grep -q '$MARKER' /proc/version 2>/dev/null; then echo P2_PASS=1; else echo P2_PASS=0; fi
$p3_block
poweroff -f
INIT
  chmod +x "$init/init"
  check_init_no_klp_glob "$init/init"
  ( cd "$init" && find . -print0 | cpio --null -o --format=newc | gzip -9 ) >"$Q/initrd-second-pin.cpio.gz"
  serial="$OUT/predicate-serial.log"
  : >"$serial"
  timeout 180 qemu-system-x86_64 -kernel "$BZ" -initrd "$Q/initrd-second-pin.cpio.gz" \
    -append "console=ttyS0 panic=1 nokaslr init=/init" -m 512 -nographic -no-reboot \
    -serial file:"$serial" 2>/dev/null || true
  grep -E 'INSMOD|KLP_|P2_PASS|P3_|PRE_' "$serial" | tee -a "$OUT/predicate-transcript.txt" || true
  {
    echo "HOST=$(hostname)"
    echo "PIN_TAG=$PIN_TAG"
    echo "PIN_COMMIT=$(git -C "$DP" rev-parse HEAD)"
    sha256sum "$BZ" | awk '{print "BZIMAGE_SHA256="$1}'
    echo "SMOKE_CASE=LP-CVE-2023-52577-contract"
  } | tee "$OUT/pin.txt"
  echo "SECOND_PIN_SMOKE_DONE=$(date -u +%FT%TZ)" | tee "$OUT/SECOND_PIN_SMOKE_DONE.txt"
} >>"$LOG" 2>&1
