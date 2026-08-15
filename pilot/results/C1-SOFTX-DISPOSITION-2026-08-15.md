# C1 SoftX disposition — tonight (15 Aug 2026)

**Item:** True cross-pipeline `klp-build-upstream` vs `kpatch-build`  
**Checklist:** CORPUS-CHECKLIST · CORPUS-BATTLE-PLAN

## SoftX close (tonight)

| Claim SoftX may make | Evidence |
| --- | --- |
| Pipeline baseline on **v6.6.47** | **B1 DONE** — hand-build klp vs `kpatch-build` 0.9.11 · `LP-CORPUS-01-pipeline/` |
| Predicates agree across those two builders | **DONE** — P2/P3 both pass (`14-run-corpus-c1-predicates.sh` artifacts) |

| Claim SoftX must **not** make | Why |
| --- | --- |
| `klp-build-upstream` (in-tree 6.19+) equivalence rates | Tool **absent** on 6.6.47 pin |

## Paper 2 reopen (started tonight)

1. Clone Linux ≥6.19 to `/opt/atlas/livepatch-corpus/linux-c1-619` (fetch in flight).  
2. Full harness re-pin + re-validation.  
3. Run `klp-build` vs `kpatch-build` on same logical fix.  
4. Only then check **C1** on CORPUS-CHECKLIST.

## Gate statement — **C1 CLOSED for SoftwareX**

SoftwareX treats **B1** as the pipeline baseline on the case-study pin.  
Checklist row **C1** remains open for **Paper 2** until 6.19+ evidence lands — not a SoftX EM blocker after this disposition.
