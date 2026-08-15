# C1 SoftX disposition — tonight (15 Aug 2026)

**Item:** True cross-pipeline `klp-build-upstream` vs `kpatch-build`  
**Checklist:** CORPUS-CHECKLIST · CORPUS-BATTLE-PLAN

## SoftX close (tonight)

| Claim SoftX may make | Evidence |
| --- | --- |
| Pipeline baseline on **v6.6.47** | **B1 DONE** — hand-build klp vs `kpatch-build` 0.9.11 · `LP-CORPUS-01-pipeline/` |
| Predicates agree across those two builders | **DONE** — P2/P3 both pass |

| Claim SoftX must **not** make | Why |
| --- | --- |
| `klp-build-upstream` equivalence rates | Requires 6.19+ re-pin (started tonight) |

## Paper 2 — started tonight

| Field | Value |
| --- | --- |
| Tree | `/opt/atlas/livepatch-corpus/linux-c1-619` |
| Tag | `v6.19` |
| `scripts/livepatch/klp-build` | **PRESENT** |
| Full bzImage + comparison | After C6 + Dirty Pipe bzImage free CPU |

## Gate statement — **C1 CLOSED for SoftwareX**

SoftwareX treats **B1** as the pipeline baseline on the case-study pin.  
Checklist **C1** stays open for **Paper 2** until `klp-build` vs kpatch evidence lands on v6.19 — not a SoftX EM blocker after this disposition.
