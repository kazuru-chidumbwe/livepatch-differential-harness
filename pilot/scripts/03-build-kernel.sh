#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
DEST="${WORK_ROOT:-/var/lib/livepatch-pilot}/linux"
cd "$DEST"
make -j"${BUILD_JOBS:-$(nproc)}" 2>&1 | tee "$ROOT/pilot/results/kernel.build.log"
make modules_install INSTALL_MOD_PATH="$ROOT/pilot/build/modules" 2>&1 | tee -a "$ROOT/pilot/results/kernel.build.log"
cp arch/x86/boot/bzImage "$ROOT/pilot/build/bzImage"
cp System.map "$ROOT/pilot/build/System.map"
cp vmlinux "$ROOT/pilot/build/vmlinux"
sha256sum arch/x86/boot/bzImage vmlinux .config | tee "$ROOT/pilot/results/kernel.sha256"
