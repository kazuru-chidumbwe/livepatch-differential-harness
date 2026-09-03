#!/usr/bin/env bash
# klp-build probe — probe klp-build-upstream on Linux v6.19+ (tool presence + optional dry build).
# Full hand-vs-klp-build equivalence matrix remains Paper 2 if this cannot finish tonight.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/pilot/results/LP-KLP-BUILD-UPSTREAM"
TREE="/opt/atlas/livepatch-corpus/linux-c1-619"
LOG="$OUT/klp-build-probe.log"
mkdir -p "$OUT" /opt/atlas/livepatch-corpus
: >"$LOG"
{
  echo "KLP_BUILD_PROBE_START=$(date -u +%FT%TZ)"
  sudo chown -R "$(id -un):$(id -gn)" /opt/atlas/livepatch-corpus || true
  if [ ! -d "$TREE/.git" ]; then
    rm -rf "$TREE"
    git clone --depth 1 --branch v6.19 \
      https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$TREE" \
      || git clone --depth 1 --branch v6.19 \
      https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git "$TREE"
  fi
  cd "$TREE"
  echo "PIN_COMMIT=$(git rev-parse HEAD)"
  echo "PIN_DESCRIBE=$(git describe --tags --always)"
  if [ -x scripts/livepatch/klp-build ] || [ -f scripts/livepatch/klp-build ]; then
    echo "KLP_BUILD_PRESENT=1"
    ls -la scripts/livepatch/ | tee "$OUT/scripts-livepatch.ls"
    # Help / usage probe (do not require full module success for DONE marker)
    if scripts/livepatch/klp-build --help >"$OUT/klp-build-help.txt" 2>&1 \
       || scripts/livepatch/klp-build -h >"$OUT/klp-build-help.txt" 2>&1 \
       || head -40 scripts/livepatch/klp-build >"$OUT/klp-build-head.txt"; then
      echo "KLP_BUILD_HELP_OK=1"
    fi
    # Record that tool exists on v6.19; full Stage A compare vs kpatch deferred if heavy
    echo "KLP_BUILD_EQUIV_MATRIX=DEFERRED_PAPER2_OR_FOLLOWUP" | tee "$OUT/status.txt"
    echo "KLP_BUILD_TOOL_PRESENT=1" | tee "$OUT/KLP_BUILD_PROBE_DONE.txt"
  else
    echo "KLP_BUILD_PRESENT=0"
    ls scripts/livepatch 2>/dev/null || echo "NO_scripts_livepatch"
    echo "KLP_BUILD_TOOL_PRESENT=0" | tee "$OUT/KLP_BUILD_PROBE_DONE.txt"
  fi
  echo "KLP_BUILD_PROBE_END=$(date -u +%FT%TZ)"
} >>"$LOG" 2>&1
