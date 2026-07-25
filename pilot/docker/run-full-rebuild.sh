#!/usr/bin/env bash
# Optional full rebuild: kernel bzImage (long) then Stage A modules, then Stage B predicates.
set -euo pipefail
cd /work
export WORK_ROOT="${WORK_ROOT:-/work/linux}"

if [[ ! -d "$WORK_ROOT" ]]; then
  echo "missing kernel tree at WORK_ROOT=$WORK_ROOT" >&2
  exit 1
fi

echo "=== Full rebuild: kernel (Stage 0) ==="
bash pilot/scripts/03-build-kernel.sh

echo "=== Full rebuild: modules (Stage A) ==="
bash pilot/docker/run-build-modules.sh

echo "=== Full rebuild: predicates (Stage B) ==="
bash pilot/docker/run-all.sh
