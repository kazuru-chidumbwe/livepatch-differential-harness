#!/usr/bin/env bash
# Predicate workload for LP-PILOT-02: /proc/version
set -euo pipefail
OUT="${1:-/tmp/lp-pilot-version.txt}"
cat /proc/version | tee "$OUT"
if grep -q 'LP-PILOT-02 patched-by-harness' "$OUT"; then
  echo 'P2: PATCHED_MARKER=1'
else
  echo 'P2: PATCHED_MARKER=0'
fi
