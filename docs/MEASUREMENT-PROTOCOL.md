# Measurement protocol (v2 — pilot-gated)

**Supersedes** v1 Canonical-reference three-channel protocol.  
**Source:** [`pilot/PILOT-GATE-DELIVERABLES.md`](../../../pilot/PILOT-GATE-DELIVERABLES.md)

**Status:** pilot **gate closed** 2026-07-10 — see [`pilot/PILOT-GATE-DELIVERABLES.md`](../pilot/PILOT-GATE-DELIVERABLES.md).

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

## Pilot gate (blocks corpus)

| Deliverable | Required |
| --- | --- |
| Trivial single-function fix | ✓ |
| Hand-built `klp_patch` + relocation table | ✓ |
| Revert-and-retest | ✓ |
| Perturbation sanity | ✓ |
| First predicate table | ✓ |

## Outcomes per case

Report: **trace-equivalent**, **divergent (mechanism X)**, or **inconclusive (coverage bound)** — never silent PASS without stated bounds.

## Pipelines

- `kpatch-build` (legacy)  
- `klp-build` (upstream 6.19+)  
- SUSE kgraft-patch — **excluded** (packaging wrapper; see `pilot/results/kgraft-patch-pipeline-check.md`)
