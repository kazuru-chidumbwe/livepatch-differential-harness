#!/usr/bin/env bash
# Hand-build LP-PILOT-01 klp_patch module against pinned kernel tree.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
HB="$ROOT/pilot/handbuild/LP-PILOT-01"
RES="$ROOT/pilot/results"
mkdir -p "$RES"
LOG="$RES/handbuild-failure.log"
: >"$LOG"

iter=0
max_iter=5
while [ "$iter" -lt "$max_iter" ]; do
  iter=$((iter + 1))
  echo "--- iteration $iter ---" >>"$LOG"
  if make -C "$HB" clean KDIR="$WORK_ROOT/linux" >>"$LOG" 2>&1 && \
     make -C "$HB" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$WORK_ROOT/linux" >>"$LOG" 2>&1; then
    echo "$iter" >"$RES/handbuild-iterations.txt"
    echo "hand-build OK iteration=$iter"
    exit 0
  fi
done

echo "$iter" >"$RES/handbuild-iterations.txt"
echo "hand-build FAILED after $iter iterations" >&2
tail -30 "$LOG" >&2
exit 1
