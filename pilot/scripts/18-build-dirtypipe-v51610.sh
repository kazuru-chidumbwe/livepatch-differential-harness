#!/usr/bin/env bash
# Fetch and build Linux v5.16.10 Dirty Pipe pin, then PRE-gated QEMU re-run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DP="/opt/atlas/livepatch-corpus/linux-dirtypipe"
LOG="/opt/atlas/livepatch-corpus/dirtypipe-build.log"
JOBS="${BUILD_JOBS:-$(nproc)}"
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
{
  echo "DIRTYPIPE_BUILD_START=$(date -u +%FT%TZ)"
  sudo mkdir -p /opt/atlas/livepatch-corpus
  sudo chown -R "$(id -un):$(id -gn)" /opt/atlas/livepatch-corpus
  if [ ! -d "$DP/.git" ]; then
    rm -rf "$DP"
    git clone --depth 1 --branch v5.16.10 \
      https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$DP"
  fi
  cd "$DP"
  git rev-parse HEAD
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
  append_cfg CONFIG_FUNCTION_TRACER y
  append_cfg CONFIG_FTRACE y
  append_cfg CONFIG_KPROBES y
  append_cfg CONFIG_MODULES y
  append_cfg CONFIG_MODULE_SIG n
  make olddefconfig
  make -j"$JOBS" bzImage modules_prepare
  echo "DIRTYPIPE_BUILD_OK=$(date -u +%FT%TZ)"
  export DIRTYPIPE_LINUX="$DP"
  export DIRTYPIPE_BZ="$DP/arch/x86/boot/bzImage"
  export WORK_ROOT="$WORK_ROOT"
  cd "$ROOT"
  bash "$ROOT/pilot/scripts/17-run-eisej-v020.sh"
} >>"$LOG" 2>&1
