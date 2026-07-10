# Predicate table — LP-PILOT-01-cmdline

**Date:** 2026-07-10  
**Case:** `cmdline_proc_show` hand-built ground truth  
**Harness type:** Differential regression (not formal proof)

## Lockdep vs custom BPF — concrete decision

| Option | LP-PILOT-01 | When used in corpus |
| --- | --- | --- |
| **lockdep report import** | **No** | Cases where patched function or callees hold `lock_class` keys per `lockdep` report from `CONFIG_PROVE_LOCKING` build |
| **Custom BPF kprobe/fentry** | **No** | Kernel-only side effects not visible via syscall/`/proc`/`ftrace` export; attach cost justified by coverage gap |
| **Userspace `/proc` output check** | **Yes (primary)** | User-visible seq_file handlers (this pilot) |
| **ftrace (future)** | Optional | When predicate needs kernel timing/path evidence beyond `/proc` |

**Rationale:** `cmdline_proc_show` only mutates seq_file output; no locks in the hot path on `v6.6.47`. Userspace predicates give full coverage of the stated trace-equivalence surface for this case.

## Predicate table

| ID | Predicate | Observable | Pre-patch | Post-patch | Post-revert | Measured (pilot) |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | `/proc/cmdline` read succeeds | `cat /proc/cmdline` exit 0 | PASS | PASS | PASS | PASS (QEMU) |
| P2 | Patched marker present | stdout contains `this has been live patched` | FAIL | PASS | FAIL | PASS (`P2_PASS=1`) |
| P3 | Revert restores output | stdout matches pre-patch cmdline | — | — | PASS | PASS (`P3_PASS=1`) |
| P4 | Wrong-symbol load rejected | `insmod` bad module | — | — | — | PASS (`INSMOD_RC=1`) |
| P5 | lockdep class ordering | `lockdep` report | N/A | N/A | N/A | **Not applicable** |
| P6 | BPF kprobe firing | BPF program map | N/A | N/A | N/A | **Deferred** |

## Coverage bound (explicit)

| Dimension | In scope (pilot) | Out of scope |
| --- | --- | --- |
| User-visible output | `/proc/cmdline` bytes | Other `/proc` nodes |
| Syscall returns | `read()` success/failure | Full strace matrix |
| ftrace | — | Function graph not collected |
| kcov basic-block % | — | **Not measured** in gate QEMU run (kernel built with `CONFIG_KCOV=y` for later) |
| lockdep | — | No lock classes in target |
| Multi-pipeline ELF diff | — | Stage-1 after corpus micro-cases |

## Workload script

`pilot/cases/LP-PILOT-01-cmdline/workload.sh` — implements P1/P2 for host-side runs.

## Stage-2 note

When `kpatch-build` vs `klp-build` artifacts exist for the same source patch, P2 becomes the **primary equivalence oracle**; structural Stage-1 ELF tuple diff on `.rela.text` / `seq_printf` addends detects mechanism 1 (relocation) divergences.
