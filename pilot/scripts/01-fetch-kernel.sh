#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
DEST="${WORK_ROOT:-/var/lib/livepatch-pilot}/linux"
mkdir -p "$(dirname "$DEST")"
if [[ ! -d "$DEST/.git" ]]; then
  git clone --depth 1 --branch "$KERNEL_TAG" "$KERNEL_REPO" "$DEST"
fi
cd "$DEST"
git rev-parse HEAD | tee "$ROOT/pilot/results/kernel.commit"
echo "KERNEL_TREE=$DEST"
