# Shared QEMU-init helpers (`klp-predicates.sh`)

**Purpose:** harden post-revert (P3) checks so package serial logs distinguish transition failure from marker-contract failure.

| Field | Meaning |
| --- | --- |
| `KLP_ENABLED` | Value of `enabled` under each livepatch sysfs dir after load (or `missing`) |
| `KLP_TRANSITION` | Value of `…/transition` after load |
| `P3_TRANSITION_COMPLETE` | Disable completed (`transition` reached 0 within timeout) |
| `P3_ENABLED_ZERO` | All livepatch dirs report `enabled=0` after wait |
| `P3_BASELINE_OBSERVED` | Marker absent from the stated `/proc` contract file |
| `P3_TIMEOUT` | Transition wait exhausted |
| `P3_PASS` | Composite: transition complete ∧ enabled zero ∧ baseline observed |

Usage from a run script:

```bash
# shellcheck source=/dev/null
source "$ROOT/pilot/scripts/lib/klp-predicates.sh"
cat >"$init/init" <<INIT
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
insmod /mod.ko
echo INSMOD_RC=\$?
sleep 1
$(emit_klp_post_load_status)
if grep -q '$MARKER' $PROC_FILE; then echo P2_PASS=1; else echo P2_PASS=0; fi
$(emit_p3_hardened_revert "$MARKER" "$PROC_FILE" 30)
poweroff -f
INIT
check_init_no_klp_glob "$init/init"
```
