#!/usr/bin/env bash
set -euo pipefail
DP=/opt/atlas/livepatch-corpus/linux-dirtypipe
LOG=/opt/atlas/livepatch-corpus/dirtypipe-build.log
ROOT=/home/boma/Project-Atlas/repos/livepatch-differential-harness
JOBS="$(nproc)"
{
  echo "DIRTYPIPE_RESUME=$(date -u +%FT%TZ)"
  python3 - <<'PY'
from pathlib import Path
p=Path("/opt/atlas/livepatch-corpus/linux-dirtypipe/tools/lib/subcmd/subcmd-util.h")
t=p.read_text()
old="""static inline void *xrealloc(void *ptr, size_t size)
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
new="""static inline void *xrealloc(void *ptr, size_t size)
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
elif old not in t:
    raise SystemExit("xrealloc block not found")
else:
    p.write_text(t.replace(old, new, 1))
    print("PATCHED_XREALLOC")
PY
  cd "$DP"
  make -j"$JOBS" bzImage modules_prepare
  echo "DIRTYPIPE_BUILD_OK=$(date -u +%FT%TZ)"
  export WORK_ROOT=/home/boma/livepatch-pilot
  export DIRTYPIPE_LINUX="$DP"
  export DIRTYPIPE_BZ="$DP/arch/x86/boot/bzImage"
  unset CURDIR || true
  cd "$ROOT"
  bash "$ROOT/pilot/scripts/17-run-v020.sh"
  echo "DIRTYPIPE_PREGATED_DONE=$(date -u +%FT%TZ)"
} >>"$LOG" 2>&1
