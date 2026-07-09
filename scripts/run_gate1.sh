#!/usr/bin/env bash
# Gate 1: positive-control relocation error must be detected.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "gate1: NOT YET IMPLEMENTED"
echo "  Planned check:"
echo "    inject single-byte relocation offset error in klp-build output"
echo "    verify Channel 1 and/or Channel 2 reports DIVERGE"
exit 2
