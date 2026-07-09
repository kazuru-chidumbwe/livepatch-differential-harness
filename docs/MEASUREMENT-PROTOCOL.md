# Measurement protocol (pre-registered)

This document is the falsifiable measurement contract for the livepatch build-tool observational equivalence study.

**Status:** design frozen; execution pending Gate 0/1.

## Goal

Test **observational equivalence** of livepatch modules produced by different build pipelines from the same source patch. The in-kernel livepatch runtime is shared; divergence must originate in build-time artifacts manifesting as structural, functional, or operational differences.

## Definitions

- **Tool:** a livepatch build pipeline producing a `.ko` from an identical source patch under the pinned toolchain.
- **Reference:** Canonical prebuilt module — **functional and operational reference only** (structural equivalence is primarily tool-vs-tool under pinned toolchain).
- **Cell:** one `(patch × tool)` evaluation unit.

Per-channel outcomes: **PASS**, **DIVERGE**, **INCONCLUSIVE**, **N/A**.

---

## Channel 1 — Structural equivalence (ELF)

**Primary signal:** livepatch relocation sections per [kernel livepatch module ELF format](https://docs.kernel.org/livepatch/module-elf-format.html):

- Section names: `.klp.rela.<objname>.<section_name>`
- Compare normalized **SHT_RELA** tuples (include addends):

```
(objname, section_name, r_offset, r_info_type, symbol_name, r_addend)
```

**Additional checks:**

- relocation section invariants (naming, flags)
- relocation → symbol reference validity
- livepatch metadata sections compared semantically (handle `.init.*` naming where relevant)

**Canonicalization (ignore):** build IDs, comments/notes, timestamps, padding, symbol/section ordering, path-derived debug noise.

**DIVERGE if:** tuple multiset mismatch, invariant violation, or invalid symbol reference.

---

## Channel 2 — Functional equivalence (runtime probes)

**Requirements:**

- deterministic probe suite per patch
- bitwise-comparable outputs (stdout/stderr, trace/kprobe values, asserted kernel state)
- run only after verified livepatch transition

**Coverage gate:** ≥95% branch coverage in patched function(s) — else **INCONCLUSIVE**.

**Compare:** tool module vs Canonical reference behavior (or declared fallback with caveats).

**DIVERGE if:** any probe output mismatch vs reference.

---

## Channel 3 — Operational signatures

**Window:** module insert → transition complete or timeout.

**Normalize:** strip timestamps/PIDs; normalize addresses and volatile tokens.

**Automatic DIVERGE:** load failure, transition timeout/failure, OOPS/BUG/panic/stack trace, new error-level messages absent in reference.

**WARN-only:** recorded; DIVERGE only if not allowlisted and reproducible or correlated with Channel 1/2.

---

## Cell aggregation

1. Any channel **DIVERGE** → cell **DIVERGE**
2. Else any required channel **INCONCLUSIVE** → cell **INCONCLUSIVE**
3. Else → cell **PASS**

---

## Gating milestones

| Gate | Requirement |
| --- | --- |
| **0** | Same-tool two builds → identical normalized ELF; same module two runs → identical probe/log outputs |
| **1** | Positive-control relocation error detected by Channel 1 and/or 2; not normalized away |

---

## Divergence taxonomy (pre-defined)

| Category | Description |
| --- | --- |
| Relocation mismatch | Wrong offset/symbol/addend or missing relocation |
| Symbol resolution failure | Unresolved local/exported symbol → wrong replacement |
| Code generation difference | Different `.text` despite correct relocations (flag/tool issue) |
| Struct initialization bug | Wrong `klp_func` / `klp_object` fields |
| Operational anomaly | Load failure, unique WARN/ERROR, transition hang |

---

## References

- [Livepatch module ELF format](https://docs.kernel.org/livepatch/module-elf-format.html)
- [kpatch maintenance notice / klp-build](https://github.com/dynup/kpatch/issues/1498)
- Study design source: `private/Livepatch-Build.md` (private programme workspace)
