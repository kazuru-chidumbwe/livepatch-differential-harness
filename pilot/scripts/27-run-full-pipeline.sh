#!/usr/bin/env bash
# Orchestrate INCLUDE packs, PRE population, klp-build probe, then second-pin smoke.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
H="$ROOT"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
cd "$H"
find "$H/pilot/scripts" -name '2*.sh' -o -name 'gen_*.py' | xargs -r sed -i 's/\r$//' || true
chmod +x "$H/pilot/scripts"/23-*.sh "$H/pilot/scripts"/24-*.sh "$H/pilot/scripts"/25-*.sh "$H/pilot/scripts"/26-*.sh

echo "=== INCLUDE packs ==="
bash "$H/pilot/scripts/23-run-include-packs.sh"

echo "=== PRE population ==="
bash "$H/pilot/scripts/25-run-pre-population-scan.sh"

echo "=== klp-build probe (clone may take a while) ==="
bash "$H/pilot/scripts/26-probe-klp-build-upstream.sh"

echo "=== second-pin smoke (kernel build — longest) ==="
bash "$H/pilot/scripts/24-build-second-pin.sh"

echo "FULL_PIPELINE_DONE=$(date -u +%FT%TZ)" | tee "$H/pilot/results/FULL-PIPELINE-DONE.txt"
