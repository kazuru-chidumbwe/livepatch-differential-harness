#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/pilot/env/pins.env"
DEST="${WORK_ROOT:-/var/lib/livepatch-pilot}/linux"
cd "$DEST"
make defconfig
append_cfg() {
  local key=$1 val=$2
  if grep -q "^${key}=" .config; then
    sed -i "s/^${key}=.*/${key}=${val}/" .config
  else
    echo "${key}=${val}" >> .config
  fi
}
append_cfg CONFIG_LIVEPATCH y
append_cfg CONFIG_MODULE_UNLOAD y
append_cfg CONFIG_KALLSYMS_ALL y
append_cfg CONFIG_DEBUG_INFO y
append_cfg CONFIG_DEBUG_INFO_DWARF4 y
append_cfg CONFIG_FUNCTION_TRACER y
append_cfg CONFIG_FTRACE y
append_cfg CONFIG_KPROBES y
append_cfg CONFIG_KCOV y
append_cfg CONFIG_KCOV_INSTRUMENT_ALL y
append_cfg CONFIG_MODULES y
append_cfg CONFIG_MODULE_SIG n
make olddefconfig
mkdir -p "$ROOT/pilot/results"
cp .config "$ROOT/pilot/results/kernel.config"
echo "config written: $ROOT/pilot/results/kernel.config"
