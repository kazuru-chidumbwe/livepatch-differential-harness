#!/usr/bin/env bash
# Stage B: predicate suite. Rebuilds case modules from source as each script runs
# (requires WORK_ROOT/linux). Optional Stage A first via BUILD_FROM_SOURCE=1.
set -euo pipefail
cd /work
export WORK_ROOT="${WORK_ROOT:-/work/linux}"
export PATH="/work/pilot/scripts:$PATH"

echo "=== livepatch-pilot run-all (Stage B predicates) ==="
echo "kernel: $(grep '^KERNEL_VERSION=' pilot/env/pins.env 2>/dev/null || echo pinned-v6.6.47)"
echo "WORK_ROOT=$WORK_ROOT"

if [[ "${BUILD_FROM_SOURCE:-0}" == "1" ]]; then
  bash pilot/docker/run-build-modules.sh
fi

fail=0
run() {
  local name="$1" script="$2"
  echo
  echo ">>> $name"
  if bash "$script"; then
    echo ">>> $name: OK"
  else
    echo ">>> $name: FAIL (rc=$?)"
    fail=$((fail + 1))
  fi
}

[ -f pilot/build/bzImage ] || { echo "missing pilot/build/bzImage — build with pilot/scripts/03-build-kernel.sh or provide pin artifact"; exit 1; }
[ -d "$WORK_ROOT" ] || { echo "missing WORK_ROOT=$WORK_ROOT (needed to compile handbuild modules from source)"; exit 1; }

run "LP-PILOT-02 validation" pilot/scripts/08-run-lp-pilot-02.sh
run "B1 pipeline baseline" pilot/scripts/14-run-corpus-c1-predicates.sh
run "C2 func-sym" pilot/scripts/12-run-corpus-c2-func-sym.sh
run "C3 survivable-sym" pilot/scripts/13-run-corpus-c3-survivable-sym.sh

echo
echo "=== run-all complete: $fail failure(s) ==="
exit "$fail"
