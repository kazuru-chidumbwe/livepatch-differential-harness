# Corpus package closeout — 15/16 Aug 2026 (closed)

**Sponsor:** close C1 / C4 / C6 / Dirty Pipe for package.  
**Scope:** instrument / case-study packs.
**Dirty Pipe:** Option A QEMU = package · **CLOSED** 16 Aug (lab + local sync).

| Gate | package | Evidence |
| --- | --- | --- |
| Pre-corpus B1/C2/C3/C5 | **CLOSED** | Existing `LP-CORPUS-*` packs |
| **C4** stratification | **CLOSED** | `cve-triage-table.md` — 35 rows |
| **C1** true `klp-build-upstream` | **CLOSED for package via B1** | Paper 2 keeps true C1 |
| **C6** kpatch `-O2`/`-Os` | **CLOSED** | `LP-CORPUS-06-kpatch-opt/` · `C6_KPATCH_OPT_DONE` |
| **Dirty Pipe** Option A QEMU | **CLOSED** | `LP-CORPUS-DIRTYPIPE/` · `DIRTYPIPE_QEMU_DONE` |

## Dirty Pipe pin (Option A — package)

```
KERNEL_TAG=v5.16.10
KERNEL_COMMIT=528cecfa5af09631f0589efe9eacbd543c8c9db1
WORK_ROOT=/opt/atlas/livepatch-corpus
BZIMAGE_SHA256=CF5C1899E0CD0A04D16C65A5BDF24BB05E1590635E31F83C24461EFDC2390119
```

Predicates: `INSMOD_RC=0` · `P2_PASS=1` · `P3_PASS=0`.

## package acceptance

- [x] `DIRTYPIPE_BZ_DONE`  
- [x] Handbuild loadable · `INSMOD_RC=0`  
- [x] QEMU transcripts · `DIRTYPIPE_QEMU_DONE`  
- [x] Forensic pack under `pilot/results/LP-CORPUS-DIRTYPIPE/` (synced local 16 Aug)  
- [x] C6 pack under `pilot/results/LP-CORPUS-06-kpatch-opt/` (synced local 16 Aug)

## Paper 2 reopen

1. Finish C1 on linux-c1-619 (`klp-build` vs kpatch).  
2. Execute INCLUDE shortlist / stratified rates.  
3. Prevalence / production measurement.
