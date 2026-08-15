# LP-CORPUS-DIRTYPIPE — Dirty Pipe capstone (stub)

**CVE:** CVE-2022-0847  
**Status:** stub only — see `pilot/DIRTY-PIPE-CAPSTONE.md`  
**Pin:** TBD (pre-fix vulnerable kernel; **not** v6.6.47)

## Intended layout (when Option A starts)

```
pilot/cases/LP-CORPUS-DIRTYPIPE/
  case.env
  workload.sh
  README.md
pilot/handbuild/LP-CORPUS-DIRTYPIPE/
  livepatch-dirtypipe.c
  Makefile
pilot/patches/LP-CORPUS-DIRTYPIPE-fix.patch
pilot/results/LP-CORPUS-DIRTYPIPE/
```

Do not invent predicates until the vulnerable pin boots and the upstream fix symbols are identified on that tree.
