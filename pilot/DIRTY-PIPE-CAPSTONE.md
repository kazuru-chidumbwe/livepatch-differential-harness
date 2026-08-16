# Dirty Pipe capstone — plan (CVE-2022-0847)

**Status:** SoftX Option A QEMU **CLOSED** 16 Aug (lab + harness sync)  
**Class:** CAPSTONE  
**Triage:** `pilot/results/cve-triage-table.md`  
**Disposition:** `pilot/results/DIRTYPIPE-SOFTX-DISPOSITION-2026-08-15.md`  
**Pack:** `pilot/results/LP-CORPUS-DIRTYPIPE/`

## Pin

| Field | Value |
| --- | --- |
| Tag | `v5.16.10` (vulnerable; fix in `v5.16.11`) |
| Commit | `528cecfa5af09631f0589efe9eacbd543c8c9db1` |
| Tree | `/opt/atlas/livepatch-corpus/linux-dirtypipe` |
| bzImage SHA-256 | `CF5C1899E0CD0A04D16C65A5BDF24BB05E1590635E31F83C24461EFDC2390119` |
| Predicates | `INSMOD_RC=0` · `P2_PASS=1` · `P3_PASS=0` |

## SoftX bar

| Criterion | Status |
| --- | --- |
| Capstone in C4 table | **DONE** |
| Vulnerable pin | **DONE** |
| Handbuild on pin | **DONE** |
| bzImage + QEMU P2/P3 | **DONE** |
| Forensic pack synced | **DONE** |

## Paper 2

Prevalence / stratified rates / true `klp-build-upstream` only — **not** Dirty Pipe QEMU.
