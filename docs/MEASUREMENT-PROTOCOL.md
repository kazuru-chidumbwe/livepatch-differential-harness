# Measurement protocol (v2 — pilot-gated)

**Supersedes** v1 Canonical-reference three-channel protocol.  
**Source:** pilot gate design in this repo (`pilot/PILOT-GATE-DELIVERABLES.md`, package methodology).

**Status:** pilot gate **closed** 2026-07-10 (LP-PILOT-01 toolchain + LP-PILOT-02 behavioral claim). See [`pilot/PILOT-GATE-DELIVERABLES.md`](../pilot/PILOT-GATE-DELIVERABLES.md).

## Goal

Test whether independent livepatch build pipelines produce **trace-equivalent** fixes for the same source patch, and attribute divergences to one of five mechanisms (relocation, inline scope, jump labels, codegen, symver/CRC).

## Equivalence

**Trace-equivalence** over syscall returns, ftrace events, and user-visible memory writes under defined execution contexts — modulo timing and register allocation unless semantically observable.

## Ground truth

- **Hand-built `klp_patch`** per pinned kernel commit (not reusable across versions).  
- **Not** vendor prebuilt modules as validation (qualitative discussion only).  

**Validation layers:**

1. Behavioral check  
2. Revert-and-retest  
3. Perturbation sanity (shift relocation addend; must detect)  

## Dynamic confirmation

- Per-case predicate suite (differential regression harness — not formal proof).  
- Lock-ordering from lockdep where feasible.  
- Every result states coverage bound (kcov basic-block %, out-of-scope items).  

## Structural stage (Stage 1)

Normalized `.klp.rela.*` tuples per [kernel livepatch ELF format](https://docs.kernel.org/livepatch/module-elf-format.html):

```
(objname, section_name, r_offset, r_info_type, symbol_name, r_addend)
```

Real ELF divergences between pipelines feed the predicate harness (primary mutation source).

## Pilot gate (closed 2026-07-10)

Two-phase pilot: **LP-PILOT-01** (toolchain validation) + **LP-PILOT-02** (loadable **data-relocation** perturbation). **Do not cite PILOT-01 alone** for behavioral sensitivity.

Across two toolchain-validation cases we encountered **zero iterations requiring correction**; whether this holds for cases involving cross-object relocations or control-flow-affecting patches **remains untested** and is the **first open question of the corpus phase**. Iteration count **1** in each pilot case is a **floor**, not a scale claim (see gate doc).

**Corpus open item:** mechanism-1 **function-symbol substitution** (loadable code-relocation) → first weak-symbol corpus case, not PILOT-03.

See [`pilot/PILOT-GATE-DELIVERABLES.md`](../pilot/PILOT-GATE-DELIVERABLES.md).

## Pilot gate deliverables (historical checklist)

## Outcomes per case

Report: **trace-equivalent**, **divergent (mechanism X)**, or **inconclusive (coverage bound)** — never silent PASS without stated bounds.

## Pipelines

- `kpatch-build` (legacy)  
- `klp-build-upstream` (`scripts/livepatch/klp-build`, kernel 6.19+)  
- `SUSE-klp-build` — optional vendor track; qualitative unless reproduced  
- `kernel-livepatch-packaging` (legacy kgraft-patch scripts) — **excluded** — see `pilot/results/kgraft-patch-pipeline-check.md`
