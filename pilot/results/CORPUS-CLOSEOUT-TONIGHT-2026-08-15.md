# Corpus SoftX closeout — tonight 15 Aug 2026

**Sponsor:** close C1 / C4 / C6 / Dirty Pipe tonight.  
**Venue:** SoftwareX P1 (instrument) · Paper 2 retains true C1 / full enum / finished capstone QEMU if not tonight.

| Gate | SoftX tonight | Evidence |
| --- | --- | --- |
| Pre-corpus B1/C2/C3/C5 | **CLOSED** | Existing `LP-CORPUS-*` packs |
| **C4** stratification | **CLOSED** | `cve-triage-table.md` — 35 rows · INCLUDE shortlist locked |
| **C1** true `klp-build-upstream` | **CLOSED for SoftX via B1** | `C1-SOFTX-DISPOSITION-2026-08-15.md` · 6.19 tree fetch for Paper 2 |
| **C6** kpatch `-O2`/`-Os` | **IN FLIGHT → must finish tonight** | Lab `/tmp/lp-c6-run.log` · `LP-CORPUS-06-kpatch-opt/` |
| **Dirty Pipe** | **Pin LOCKED · build IN FLIGHT** | `v5.16.10` @ `528cecfa…` · `/opt/atlas/livepatch-corpus/linux-dirtypipe` · skeleton handbuild |

## Dirty Pipe pin (Option A)

```
KERNEL_TAG=v5.16.10
KERNEL_COMMIT=528cecfa5af09631f0589efe9eacbd543c8c9db1
WORK_ROOT=/opt/atlas/livepatch-corpus
FIX_TAG=v5.16.11
```

SoftX must not claim Dirty Pipe QEMU predicates until `LP-CORPUS-DIRTYPIPE/` has serial logs. Capstone **class** + pin lock + skeleton = SoftX appendix-complete; live predicates = Paper 2 / morning continuation if build overruns.

## C6 acceptance (when log shows done)

- [ ] `KPATCH_BUILD_RC=0` for O2 and Os  
- [ ] Predicate transcripts with INSMOD/P2/P3  
- [ ] Checklist C6 checked  

## Paper 2 reopen (explicit)

1. Finish Dirty Pipe bzImage + handbuild + QEMU pack.  
2. Finish C1 on linux-c1-619 (`klp-build` vs kpatch).  
3. Execute INCLUDE shortlist micro-cases.
