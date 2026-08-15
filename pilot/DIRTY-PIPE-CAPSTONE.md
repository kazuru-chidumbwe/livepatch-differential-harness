# Dirty Pipe capstone — plan (CVE-2022-0847)

**Status:** Option A **IN FLIGHT** (15 Aug evening) — pin locked · bzImage building  
**Class:** CAPSTONE  
**Triage:** `pilot/results/cve-triage-table.md`

## Pin (locked tonight)

| Field | Value |
| --- | --- |
| Tag | `v5.16.10` (vulnerable; fix in `v5.16.11`) |
| Commit | `528cecfa5af09631f0589efe9eacbd543c8c9db1` |
| Tree | `/opt/atlas/livepatch-corpus/linux-dirtypipe` |
| Results | `pilot/results/LP-CORPUS-DIRTYPIPE/` |
| Skeleton | `pilot/handbuild/LP-CORPUS-DIRTYPIPE/` |

## SoftX tonight bar

| Criterion | Status |
| --- | --- |
| Capstone classified in C4 table | **DONE** |
| Vulnerable pin selected + cloned | **DONE** |
| Handbuild skeleton present | **DONE** |
| bzImage build | **IN FLIGHT** (`/tmp/lp-dirtypipe-build.log`) |
| QEMU predicates | After bzImage — continue until done tonight or mark Paper 2 if overrun |

## Capstone acceptance (full Option A)

1. Vulnerable pin boots under QEMU with `CONFIG_LIVEPATCH=y`.  
2. Hand-built livepatch applies upstream fix symbols from `v5.16.11`.  
3. Predicates encode patch contract (pipe buffer flags).  
4. Forensic pack under `pilot/results/LP-CORPUS-DIRTYPIPE/`.

## Why not on v6.6.47

Bug already fixed before SoftwareX case-study pin — replaying the fix there is the wrong experiment.
