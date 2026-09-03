#!/usr/bin/env bash
set -euo pipefail
log=/opt/atlas/livepatch-corpus/dirtypipe-build.log
i=0
while [ "$i" -lt 240 ]; do
  i=$((i + 1))
  if grep -q DIRTYPIPE__DONE "$log" 2>/dev/null; then
    echo _COMPLETE
    grep DIRTYPIPE_ "$log" || true
    tail -60 "$log"
    exit 0
  fi
  if ! pgrep -f 19-resume-dirtypipe >/dev/null; then
    echo SCRIPT_DEAD
    tail -50 "$log"
    ls -lh /opt/atlas/livepatch-corpus/linux-dirtypipe/arch/x86/boot/bzImage 2>/dev/null || echo NO_BZ
    exit 1
  fi
  sleep 30
done
echo TIMEOUT
exit 2
