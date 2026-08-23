# LivepatchDiff — in-guest KLP status + hardened P3 revert helpers
#
# Source from host run scripts when generating QEMU init:
#   # shellcheck source=/dev/null
#   source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
#   ...
#   cat >init <<INIT
#   $(emit_klp_post_load_status)
#   $(emit_p3_hardened_revert MARKER_LITERAL PROC_FILE [TIMEOUT_SEC])
#   INIT
#
# Guest must provide: sh, sleep, cat, mount (busybox). Optional: /sys/kernel/livepatch/*/force
#
# Emitted serial fields:
#   KLP_ENABLED=<0|1|missing>
#   KLP_TRANSITION=<0|1|missing>
#   P3_TRANSITION_COMPLETE=<0|1>
#   P3_ENABLED_ZERO=<0|1>
#   P3_BASELINE_OBSERVED=<0|1>
#   P3_TIMEOUT=<0|1>
#   P3_PASS=<0|1>   # 1 only if transition complete + enabled=0 + baseline observed
#
# P3_PASS remains the package-facing composite. New fields explain *why* P3 failed.

emit_klp_post_load_status() {
  cat <<'EOS'
# --- KLP post-load status ---
KLP_ENABLED=missing
KLP_TRANSITION=missing
for _d in /sys/kernel/livepatch/*; do
  [ -d "$_d" ] || continue
  if [ -f "$_d/enabled" ]; then
    KLP_ENABLED=$(cat "$_d/enabled" 2>/dev/null || echo missing)
  fi
  if [ -f "$_d/transition" ]; then
    KLP_TRANSITION=$(cat "$_d/transition" 2>/dev/null || echo missing)
  fi
done
echo "KLP_ENABLED=$KLP_ENABLED"
echo "KLP_TRANSITION=$KLP_TRANSITION"
EOS
}

# Args: marker_string proc_file [timeout_sec]
# marker_string and proc_file are expanded by the *host* into the guest script.
emit_p3_hardened_revert() {
  local marker="$1"
  local proc_file="$2"
  local timeout="${3:-30}"
  cat <<EOF
# --- hardened P3 revert (disable → wait transition → verify enabled → baseline) ---
P3_TRANSITION_COMPLETE=0
P3_ENABLED_ZERO=0
P3_BASELINE_OBSERVED=0
P3_TIMEOUT=0
for _d in /sys/kernel/livepatch/*; do
  [ -d "\$_d" ] || continue
  if [ -f "\$_d/enabled" ]; then
    echo 0 > "\$_d/enabled" 2>/dev/null || true
  fi
done
_i=0
while [ \$_i -lt ${timeout} ]; do
  _pending=0
  for _d in /sys/kernel/livepatch/*; do
    [ -f "\$_d/transition" ] || continue
    _tr=\$(cat "\$_d/transition" 2>/dev/null || echo 0)
    if [ "\$_tr" != "0" ]; then
      _pending=1
      # Pilot-only nudge if transition stalls under PID 1 (matches C3 force path).
      if [ \$_i -ge 5 ] && [ -f "\$_d/force" ]; then
        echo 1 > "\$_d/force" 2>/dev/null || true
        echo "KLP_FORCE_REVERT=1"
      fi
    fi
  done
  if [ \$_pending -eq 0 ]; then
    P3_TRANSITION_COMPLETE=1
    break
  fi
  _i=\$((_i + 1))
  sleep 1
done
if [ \$P3_TRANSITION_COMPLETE -ne 1 ]; then
  P3_TIMEOUT=1
fi
_en_ok=1
_saw=0
for _d in /sys/kernel/livepatch/*; do
  [ -f "\$_d/enabled" ] || continue
  _saw=1
  _en=\$(cat "\$_d/enabled" 2>/dev/null || echo 1)
  if [ "\$_en" != "0" ]; then
    _en_ok=0
  fi
done
if [ \$_saw -eq 1 ] && [ \$_en_ok -eq 1 ]; then
  P3_ENABLED_ZERO=1
fi
# Optional: sample PID 1 patch_state when present (informational).
if [ -r /proc/1/patch_state ]; then
  echo "PATCH_STATE_PID1=\$(cat /proc/1/patch_state 2>/dev/null || echo missing)"
fi
if grep -q '${marker}' ${proc_file} 2>/dev/null; then
  P3_BASELINE_OBSERVED=0
else
  P3_BASELINE_OBSERVED=1
fi
echo "P3_TRANSITION_COMPLETE=\$P3_TRANSITION_COMPLETE"
echo "P3_ENABLED_ZERO=\$P3_ENABLED_ZERO"
echo "P3_BASELINE_OBSERVED=\$P3_BASELINE_OBSERVED"
echo "P3_TIMEOUT=\$P3_TIMEOUT"
if [ \$P3_TRANSITION_COMPLETE -eq 1 ] && [ \$P3_ENABLED_ZERO -eq 1 ] && [ \$P3_BASELINE_OBSERVED -eq 1 ]; then
  echo "P3_PASS=1"
else
  echo "P3_PASS=0"
fi
EOF
}
