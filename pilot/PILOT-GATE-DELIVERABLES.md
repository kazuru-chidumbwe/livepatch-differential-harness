# LP pilot gate record (§4 + harness claim)

**Date:** 2026-07-10  
**Pinned kernel:** `v6.6.47` @ `4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7`  
**Gate status:** **CLOSED** (two-phase pilot)

---

## Phase labeling (required for push / paper)

| Case | Label | What it validates |
| --- | --- | --- |
| **LP-PILOT-01** | Toolchain + gate-process validation | Hand-build API, QEMU loop, revert, **load-time** wrong-symbol rejection (`insmod` fail) |
| **LP-PILOT-02** | Harness **core-claim** test | **Loadable data-relocation perturbation**; behavioral predicates (not `insmod`) catch divergence |

**Paper methodology (verbatim intent):** Do **not** cite LP-PILOT-01 alone as proof of behavioral sensitivity. **Do** cite LP-PILOT-01 **and** LP-PILOT-02 together for “methodology is buildable and sensitive to at least one loadable divergence class.”

---

## Hand-build iteration count (floor, not scale claim)

Across two toolchain-validation cases (LP-PILOT-01 and LP-PILOT-02) we encountered **zero iterations requiring correction** after the first `insmod`-successful build (iteration count **1** in each case). **Human time to gate close:** **4.0 lab hours** (toolchain bring-up, hand-build, QEMU predicates, loadable data-reloc perturbation). Whether this holds for cases involving cross-object relocations, jump labels, per-CPU/atomic sites, or control-flow-affecting patches **remains untested** and is the **first open question of the corpus phase**. This is operational good news, not evidence that hand-building scales to compound cases (e.g. Dirty Pipe capstone).

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
| Multi-type relocations | **PASS** | `R_X86_64_PLT32` (`seq_printf`, `seq_putc`); `R_X86_64_32S` (`.rodata +0`, `.rodata +0x18`) |
| Iterations to `insmod` | **1** | `pilot/results/LP-PILOT-02/handbuild-iterations.txt` |
| Good-path behavioral + revert | **PASS** | `P2_PASS=1`, `P3_PASS=1` — `validation-summary.txt` |
| Loadable **data-relocation** perturbation | **PASS** | `INSMOD_RC=0`, **`P2_PASS=0`** — `perturbation-loadable.txt` |

### What LP-PILOT-02 earns (precision)

The **loadable data-relocation perturbation** (`INSMOD_RC=0`, `P2_PASS=0`) is the evidentiary result: a module that passes the kernel's load-time checks can still be **behaviorally wrong**, and the **predicate harness** — not `insmod`, not the consistency model — catches it.

This is a **data-relocation error** (swapped `.rodata` addends — which string literal is referenced). It is a legitimate divergence class but **not** the same failure mode as **mechanism #1** in the threat model (weak-symbol / GOT resolution — a **function** relocation pointing at the wrong code symbol). We tested data relocation only; we did **not** yet test a loadable code-relocation perturbation.

### Key relocation tuples (`.rela.text`)

| r_offset | type | symbol | addend |
| --- | --- | --- | --- |
| `0x28` | `R_X86_64_32S` | `.rodata` | `0` |
| `0x2f` | `R_X86_64_32S` | `.rodata` | **`0x18`** (non-trivial) |
| `0x3b` | `R_X86_64_PLT32` | `seq_printf` | `-4` |
| `0x48` | `R_X86_64_PLT32` | `seq_putc` | `-4` |

### Perturbation B — loadable data-relocation (not mechanism #1)

**Method:** swap `.rela.text` `R_X86_64_32S` addends `0` ↔ `0x18` in built `.ko` via `perturb-rodata-addend.py` — module **loads**, wrong string referenced → **P2 fails**.

---

## Corpus-phase open item (tracked — not a PILOT-03 gate)

**Function-symbol substitution** (mechanism #1): same-signature, different-semantics **code** relocation / weak-symbol resolution — the harder case from review round 3 — **has not been attempted** in the pilot.

**Disposition:** fold into the **first mechanism-1 corpus case** (weak-symbol driver fix per bottom-up ordering), not a separate blocking pilot gate. First corpus task for mechanism #1 must include a loadable **code-relocation** perturbation test analogous to LP-PILOT-02's data-relocation test.

---

## Pipeline naming (compliance scrub — before public push)

| Qualified ID | Tool |
| --- | --- |
| `kpatch-build` | dynup/kpatch |
| `klp-build-upstream` | `scripts/livepatch/klp-build` (Linux 6.19+) |
| `SUSE-klp-build` | SUSE/klp-build + klp-ccp |
| `kernel-livepatch-packaging` | **Excluded** (wrapper) |

Run `scripts/pre-push-hygiene.sh` before any public push (hostnames, usernames, internal paths in logs/artifacts).

See `README.md`, `pipelines/README.md`, `pilot/results/kgraft-patch-pipeline-check.md`.

---

## Worthiness call

**PROCEED to depth-first corpus.** Gate closed for: **methodology is buildable** (LP-PILOT-01) **and behaviorally sensitive to at least one loadable divergence class** — specifically **loadable data-relocation error** (LP-PILOT-02). Mechanism-1 code-relocation sensitivity is explicitly deferred to corpus case #1.

**Residual bounds:** hand-build not reusable across commits; kcov % not measured in pilot QEMU (single-branch string handlers — correctly deferred); CVE triage bounded sample (n=20, single-annotator).
