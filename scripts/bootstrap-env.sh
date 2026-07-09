#!/usr/bin/env bash
# Prepare pinned toolchain and optional vendor checkouts.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "bootstrap-env: installing Python deps"
python3 -m pip install -q -r requirements.txt

VENDOR="${VENDOR_ROOT:-$ROOT/../_vendor}"
mkdir -p "$VENDOR"

echo "bootstrap-env: vendor root = $VENDOR"
echo "  (optional) clone kpatch → $VENDOR/kpatch"
echo "  (optional) kernel tree with klp-build → $VENDOR/linux"
echo ""
echo "bootstrap-env: complete (toolchain pins documented in docs/PROVENANCE.md)"
