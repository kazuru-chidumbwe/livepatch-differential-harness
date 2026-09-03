#!/usr/bin/env bash
# Re-run cite-pin packs on existing v5.16.10 bzImage (no kernel rebuild).
set -euo pipefail
LOG=/opt/atlas/livepatch-corpus/dirtypipe-build.log
H=/home/boma/Project-Atlas/repos/livepatch-differential-harness
{
  echo "V020_RERUN_START=$(date -u +%FT%TZ)"
  echo "LAB_FREE_NOTE=kind_up tetragon_down qemu_none"
  export WORK_ROOT=/home/boma/livepatch-pilot
  export DIRTYPIPE_LINUX=/opt/atlas/livepatch-corpus/linux-dirtypipe
  export DIRTYPIPE_BZ=/opt/atlas/livepatch-corpus/linux-dirtypipe/arch/x86/boot/bzImage
  unset CURDIR || true
  bash "$H/pilot/scripts/17-run-v020.sh"
  echo "DIRTYPIPE_PREGATED_DONE=$(date -u +%FT%TZ)"
} >>"$LOG" 2>&1
echo "EXIT=$?"
grep -E 'DIRTYPIPE_|V020_|FATAL|Error 2' "$LOG" | tail -40
echo '--- dirtypipe transcript ---'
cat "$H/pilot/results/LP-CORPUS-DIRTYPIPE/predicate-transcript.txt"
echo '--- pregated marker ---'
cat "$H/pilot/results/LP-CORPUS-DIRTYPIPE/DIRTYPIPE_PRE_GATED" 2>/dev/null || true
