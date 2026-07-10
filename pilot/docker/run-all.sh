#!/usr/bin/env bash
# Replay predicate suite against prebuilt pilot artifacts (no kernel rebuild).
set -euo pipefail
cd /work
export WORK_ROOT="${WORK_ROOT:-/work/linux}"
export PATH="/work/pilot/scripts:$PATH"

echo "=== livepatch-pilot run-all ==="
echo "kernel: $(grep '^KERNEL_VERSION=' pilot/env/pins.env 2>/dev/null || echo pinned-v6.6.47)"

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

[ -f pilot/build/bzImage ] || { echo "missing pilot/build/bzImage"; exit 1; }

run "LP-PILOT-02 validation" pilot/scripts/08-run-lp-pilot-02.sh
run "B1 pipeline baseline" pilot/scripts/14-run-corpus-c1-predicates.sh
run "C2 func-sym" pilot/scripts/12-run-corpus-c2-func-sym.sh
run "C3 survivable-sym" pilot/scripts/13-run-corpus-c3-survivable-sym.sh

echo
echo "=== run-all complete: $fail failure(s) ==="
exit "$fail"
