#!/usr/bin/env bash
# Orchestrate full-pipeline.1–A.4. A.1 then A.3 (fast); A.2 and A.4 are long — run A.2 foreground after A.1,
# A.4 in background if desired by caller.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
H="$ROOT"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
cd "$H"
find "$H/pilot/scripts" -name '2*.sh' -o -name 'gen_*.py' | xargs -r sed -i 's/\r$//' || true
chmod +x "$H/pilot/scripts"/23-*.sh "$H/pilot/scripts"/24-*.sh "$H/pilot/scripts"/25-*.sh "$H/pilot/scripts"/26-*.sh

echo "=== A.1 INCLUDE ==="
bash "$H/pilot/scripts/23-run-include-packs.sh"

echo "=== A.3 PRE population ==="
bash "$H/pilot/scripts/25-run-pre-population-scan.sh"

echo "=== A.4 klp-build probe (clone may take a while) ==="
bash "$H/pilot/scripts/26-probe-klp-build-upstream.sh"

echo "=== A.2 second pin (kernel build — longest) ==="
bash "$H/pilot/scripts/24-build-second-pin.sh"

echo "FULL_PIPELINE_DONE=$(date -u +%FT%TZ)" | tee "$H/pilot/results/FULL-PIPELINE-DONE.txt"
