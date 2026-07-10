#!/usr/bin/env bash
# Pre-push hygiene: grep artifact tree for hostnames, usernames, internal paths.
# Run from repo root before any public push. Exit 1 if matches found.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PATTERNS=(
  'boma'
  'lab-host'
  '172\.19\.'
  '/home/boma'
  'LAB_HOST'
  'LAB_PASSWORD'
  'private-programme'
)

PATHS=(
  pilot/results
  pilot/handbuild
  docs
  blog
  README.md
  LICENSE
)

echo "=== pre-push hygiene scan ==="
FOUND=0
for pat in "${PATTERNS[@]}"; do
  # *.log is gitignored local QEMU capture; not part of the publishable artifact tree.
  if grep -riE --exclude='*.log' "$pat" "${PATHS[@]}" 2>/dev/null | grep -v 'pre-push-hygiene.sh' | grep -v 'LAB_HOST.*example'; then
    echo "MATCH pattern: $pat"
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo "FAIL: scrub or redact matches before public push"
  exit 1
fi
echo "PASS: no obvious internal identifiers in publishable paths"
