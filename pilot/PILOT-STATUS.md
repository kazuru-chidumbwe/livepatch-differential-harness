# Pilot execution status

**Updated:** 2026-07-10  
**Case:** LP-PILOT-01-cmdline (`cmdline_proc_show`)  
**Gate:** **CLOSED** — see [`PILOT-GATE-DELIVERABLES.md`](PILOT-GATE-DELIVERABLES.md)

## Decision gate

| Step | Status | Notes |
| --- | --- | --- |
| 1. Environment pinned + QEMU | **DONE** | `v6.6.47` @ `4c1a2d4…`; lab `lab-host` |
| 2. Pilot patch selected | **DONE** | LP-PILOT-01 — kernel `livepatch-sample` target |
| 3. Hand-built `klp_patch` | **DONE** | 1 iteration; `livepatch-cmdline.ko` |
| 4. Validation layers | **DONE** | Behavioral + revert + perturbation PASS |
| 5. Predicate harness | **DONE** | [`results/predicate-table.md`](results/predicate-table.md) |
| 6. Gate deliverables | **DONE** | §4 complete in PILOT-GATE-DELIVERABLES.md |

## Ancillary gates (ordered steps 2–4)

| Item | Status |
| --- | --- |
| SUSE kgraft-patch check | **DONE** — exclude (wrapper) |
| CVE triage table | **DONE** — bounded sample |
| Predicate table + lockdep/BPF decision | **DONE** |

## Worthiness call

**PROCEED** to depth-first corpus (weak symbol → jump label → opt mismatch → inline scope → Dirty Pipe capstone).

## Time accounting

| Activity | Hours |
| --- | ---: |
| Pilot scaffolding + case selection | 1.5 |
| Environment probing | 0.5 |
| Lab kernel build + hand-build + validation | 1.25 |
| Gate deliverable tables | 0.75 |
| **Total** | **4.0** |
