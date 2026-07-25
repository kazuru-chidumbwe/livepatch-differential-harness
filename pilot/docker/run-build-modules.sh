#!/usr/bin/env bash
# Stage A: build illustrative handbuild modules from source against WORK_ROOT/linux.
# Does not rebuild bzImage (use pilot/scripts/03-build-kernel.sh for that).
set -euo pipefail
cd /work
export WORK_ROOT="${WORK_ROOT:-/work/linux}"
# shellcheck source=/dev/null
source pilot/env/pins.env

if [[ ! -d "$WORK_ROOT" ]]; then
  echo "missing kernel tree at WORK_ROOT=$WORK_ROOT" >&2
  echo "Mount a v6.6.47 tree, e.g. -v \"\$HOME/livepatch-pilot/linux:/work/linux:ro\"" >&2
  exit 1
fi

echo "=== Stage A: build modules from source ==="
echo "WORK_ROOT=$WORK_ROOT"

build_one() {
  local dir="$1"
  echo ">>> make -C $dir"
  make -C "$dir" -j"${BUILD_JOBS:-$(nproc)}" KDIR="$WORK_ROOT"
}

build_one pilot/handbuild/LP-PILOT-02
build_one pilot/handbuild/LP-CORPUS-03-seqputs
# C2 / C5 / other cases: built by their run scripts when present
if [[ -d pilot/handbuild/LP-CORPUS-02-funcsym ]]; then
  build_one pilot/handbuild/LP-CORPUS-02-funcsym || true
fi

echo "=== Stage A complete ==="
ls -la pilot/handbuild/LP-PILOT-02/*.ko pilot/handbuild/LP-CORPUS-03-seqputs/*.ko 2>/dev/null || true
