#!/usr/bin/env bash
# Fail if a generated guest init uses shell glob on livepatch sysfs paths.
# Source from host run scripts after writing $init/init:
#   # shellcheck source=/dev/null
#   source "$ROOT/pilot/scripts/lib/check-init-no-klp-glob.sh"
#   check_init_no_klp_glob "$init/init"

check_init_no_klp_glob() {
  local init_file="${1:?init path required}"
  if [[ ! -f "$init_file" ]]; then
    echo "check_init_no_klp_glob: missing file: $init_file" >&2
    return 1
  fi
  if grep -qF 'livepatch/*/enabled' "$init_file"; then
    echo "FATAL: $init_file redirects to livepatch/*/enabled (use klp-predicates.sh)" >&2
    grep -nF 'livepatch/*/enabled' "$init_file" >&2 || true
    return 1
  fi
  if grep -qE '>/sys/kernel/livepatch/\*' "$init_file"; then
    echo "FATAL: $init_file uses livepatch glob redirect under sysfs" >&2
    grep -nE '>/sys/kernel/livepatch/\*' "$init_file" >&2 || true
    return 1
  fi
}
