#!/usr/bin/env bash
# Predicate P1-P3 for LP-PILOT-01: /proc/cmdline workload
set -euo pipefail
OUT="${1:-/tmp/lp-pilot-cmdline.txt}"
cat /proc/cmdline | tee "$OUT"
if grep -q 'live patched' "$OUT"; then
  echo 'P2: PATCHED_MARKER=1'
else
  echo 'P2: PATCHED_MARKER=0'
fi
