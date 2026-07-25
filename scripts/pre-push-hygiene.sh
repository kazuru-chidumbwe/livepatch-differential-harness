#!/usr/bin/env bash
# Pre-push hygiene: grep publishable tree for hostnames, usernames, internal paths.
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
  'private programme'
  'private'
  'kazuru-chidumbwe'
  'Seke'
)

PATHS=(
  .
)

# Build debris and QEMU captures are local/regenerable; not part of the publish pin.
EXCLUDES=(
  --exclude-dir=.git
  --exclude-dir=.venv
  --exclude-dir=__pycache__
  --exclude-dir=build
  --exclude='*.log'
  --exclude='*.cmd'
  --exclude='*.mod'
  --exclude='*.mod.c'
  --exclude='*.o'
  --exclude='*.d'
  --exclude='*.ko'
  --exclude='modules.order'
  --exclude='Module.symvers'
  --exclude='pre-push-hygiene.sh'
)

echo "=== pre-push hygiene scan ==="
FOUND=0
for pat in "${PATTERNS[@]}"; do
  if grep -riE "${EXCLUDES[@]}" "$pat" "${PATHS[@]}" 2>/dev/null \
    | grep -v 'LAB_HOST.*example'; then
    echo "MATCH pattern: $pat"
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo "FAIL: scrub or redact matches before public push"
  exit 1
fi
echo "PASS: no obvious internal identifiers in publishable paths"
