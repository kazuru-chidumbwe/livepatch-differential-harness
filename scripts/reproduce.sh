#!/usr/bin/env bash
# End-to-end reproduction: build → normalize → probe → matrix.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
RESULTS_DIR="$ROOT/results/$RUN_ID"
mkdir -p "$RESULTS_DIR" "$ROOT/logs/$RUN_ID"

echo "reproduce: NOT YET IMPLEMENTED (run_id=$RUN_ID)"
echo "  output dir: $RESULTS_DIR"
echo ""
echo "  Pipeline:"
echo "    bash scripts/run_gate0.sh"
echo "    bash scripts/run_gate1.sh"
echo "    # build all (patch × tool)"
echo "    # normalize + probe + classify"
echo "    python3 classifier/matrix.py --input ... --out-dir $RESULTS_DIR"
exit 2
