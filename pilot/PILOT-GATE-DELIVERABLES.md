# LP pilot gate record (§4 + harness claim)

**Date:** 2026-07-10  
**Pinned kernel:** `v6.6.47` @ `4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7`  
**Gate status:** **CLOSED** (two-phase pilot)

---

## Phase labeling (required for push / paper)

| Case | Label | What it validates |
| --- | --- | --- |
| **LP-PILOT-01** | Toolchain + gate-process validation | Hand-build API, QEMU loop, revert, **load-time** wrong-symbol rejection (`insmod` fail) |
| **LP-PILOT-02** | Harness **core-claim** test | **Loadable** rodata perturbation; **behavioral predicates** catch divergence (`insmod` OK, `P2_PASS=0`) |

**Do not** cite LP-PILOT-01 alone as proof of behavioral sensitivity. **Do** cite LP-PILOT-01 + LP-PILOT-02 together for “methodology is buildable.”

---

## LP-PILOT-01 (toolchain validation)

| Deliverable | Result | Evidence |
| --- | --- | --- |
| Hand-built `klp_patch` | PASS | `pilot/handbuild/LP-PILOT-01/` |
| Iterations to `insmod` | **1** | `pilot/results/handbuild-iterations.txt` |
| Behavioral + revert | PASS | `P2_PASS=1`, `P3_PASS=1` |
| Perturbation (wrong symbol) | Load-time only | `INSMOD_RC=1` — **not** behavioral oracle |

---

## LP-PILOT-02 (core claim — **required**)

**Target:** `version_proc_show` — `cat /proc/version`  
**Marker:** `LP-PILOT-02 patched-by-harness`

| Deliverable | Result | Evidence |
| --- | --- | --- |
| Hand-built module | **PASS** | `pilot/handbuild/LP-PILOT-02/livepatch-version.c` |
| Multi-type relocations | **PASS** | `R_X86_64_PLT32` (`seq_printf`, `seq_putc`); `R_X86_64_32S` (`.rodata +0`, `.rodata +18`) |
| Iterations to `insmod` | **1** | `pilot/results/LP-PILOT-02/handbuild-iterations.txt` |
| Good-path behavioral + revert | **PASS** | `P2_PASS=1`, `P3_PASS=1` — `validation-summary.txt` |
| Loadable perturbation | **PASS** | `INSMOD_RC=0`, **`P2_PASS=0`** — `perturbation-loadable.txt` |

### Key relocation tuples (`.rela.text`)

| r_offset | type | symbol | addend |
| --- | --- | --- | --- |
| `0x28` | `R_X86_64_32S` | `.rodata` | `0` |
| `0x2f` | `R_X86_64_32S` | `.rodata` | **`0x18`** (non-trivial) |
| `0x3b` | `R_X86_64_PLT32` | `seq_printf` | `-4` |
| `0x48` | `R_X86_64_PLT32` | `seq_putc` | `-4` |

### Perturbation B (loadable)

**Method:** swap `.rela.text` addends `0` ↔ `24` (`0x18`) in built `.ko` via `perturb-rodata-addend.py` — module **loads**, marker string wrong → **predicates fail**.

---

## Pipeline naming (compliance scrub — before public push)

| Qualified ID | Tool |
| --- | --- |
| `kpatch-build` | dynup/kpatch |
| `klp-build-upstream` | `scripts/livepatch/klp-build` (Linux 6.19+) |
| `SUSE-klp-build` | SUSE/klp-build + klp-ccp |
| `kernel-livepatch-packaging` | **Excluded** (wrapper) |

See `README.md`, `pipelines/README.md`, `pilot/results/kgraft-patch-pipeline-check.md`.

---

## Worthiness call

**PROCEED to depth-first corpus.** Toolchain is buildable (LP-PILOT-01) and behavioral predicates detect loadable semantic divergence (LP-PILOT-02).

**Residual bounds:** hand-build not reusable across commits; kcov % not measured in pilot QEMU; CVE triage is bounded sample (n=20).
