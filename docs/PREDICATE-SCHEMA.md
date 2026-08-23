# Predicate contract schema (package v0.1.3)

Machine-readable sketch for per-case P2/P3 contracts. Operators still author semantics; this schema records what each run script encodes before QEMU replay counts as meaningful.

## Minimal YAML example

```yaml
case_id: LP-CORPUS-03-seqputs
kernel:
  version: "6.6.47"
  commit: 4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7
module: pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.ko
mutation:
  class: M1
  script: pilot/scripts/perturb-plt32-redirect.py
  args:
    from: seq_puts
    to: seq_putc
structural:
  oracle: verify-plt32-binding.py
  expect:
    - r_offset: "0x29"
      type: R_X86_64_PLT32
      symbol: seq_putc
runtime:
  qemu:
    accel: TCG
    append: "console=ttyS0 panic=1 nokaslr init=/init"
    timeout_sec: 120
  p2:
    proc_file: /proc/version
    marker: LIVEPATCH-CORPUS03-MARKER
    expect_pass: true
  p3:
    proc_file: /proc/version
    marker: LIVEPATCH-CORPUS03-MARKER
    expect_pass: true
    transition_timeout_sec: 30
    fields:
      - P3_TRANSITION_COMPLETE
      - P3_ENABLED_ZERO
      - P3_BASELINE_OBSERVED
      - P3_PASS
```

## Field notes

| Key | Meaning |
| --- | --- |
| `structural.expect[]` | Ground truth for loader-invisible binding faults (C3). Tuple `(r_offset, type, symbol)` is the published oracle. |
| `runtime.p2` | Semantic patch contract after load (`P2_PASS`). |
| `runtime.p3` | Revert contract after sysfs disable + transition wait. package `v0.1.3` composite `P3_PASS` requires transition complete ∧ enabled zero ∧ baseline observed. |
| `P3_CONTRACT_PASS` (proposed) | contract-facing revert: transition complete ∧ baseline observed; `P3_ENABLED_ZERO` stays diagnostic when sysfs lags functional revert. |
| `runtime.p3.fields` | Diagnostic sub-fields emitted by `pilot/scripts/lib/klp-predicates.sh`. |

Guest init generators must disable livepatch via directory iteration (`for _d in /sys/kernel/livepatch/*`), never `echo … > /sys/kernel/livepatch/*/enabled`. Host scripts call `check-init-no-klp-glob.sh` before packing initrd.

See also `docs/ARCHITECTURE.md`, `pilot/scripts/lib/README.md`, and `pilot/results/EVALUATION-MATRIX.md`.
