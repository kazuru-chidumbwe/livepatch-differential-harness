# Dirty Pipe capstone — plan (CVE-2022-0847)

**Status:** package appendix **CLOSED** (15/16 Aug) via pin+skeleton · Option A QEMU = Paper 2 / morning  
**Class:** CAPSTONE  
**Triage:** `pilot/results/cve-triage-table.md`  
**Disposition:** `pilot/results/DIRTYPIPE-PACKAGE-DISPOSITION-2026-08-15.md`

## Pin (locked tonight)

| Field | Value |
| --- | --- |
| Tag | `v5.16.10` (vulnerable; fix in `v5.16.11`) |
| Commit | `528cecfa5af09631f0589efe9eacbd543c8c9db1` |
| Tree | `/opt/atlas/livepatch-corpus/linux-dirtypipe` |
| Results | `pilot/results/LP-CORPUS-DIRTYPIPE/` |
| Skeleton | `pilot/handbuild/LP-CORPUS-DIRTYPIPE/` |

## corpus closeout bar

| Criterion | Status |
| --- | --- |
| Capstone classified in C4 table | **DONE** |
| Vulnerable pin selected + cloned | **DONE** |
| Handbuild skeleton present | **DONE** |
| package disposition (no false QEMU claim) | **DONE** |
| bzImage build | **PAUSED** on lab (C6 priority) — resume `/tmp/lab-resume-dirtypipe.sh` |
| QEMU predicates | **Paper 2 / morning** until serial logs exist |

## Capstone acceptance (full Option A)

1. Vulnerable pin boots under QEMU with `CONFIG_LIVEPATCH=y`.  
2. Hand-built livepatch applies upstream fix symbols from `v5.16.11`.  
3. Predicates encode patch contract (pipe buffer flags).  
4. Forensic pack under `pilot/results/LP-CORPUS-DIRTYPIPE/`.

## Why not on v6.6.47

Bug already fixed before package case-study pin — replaying the fix there is the wrong experiment.
