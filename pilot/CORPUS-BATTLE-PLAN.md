# Corpus battle plan (2026-07-10 · refreshed 15 Aug 2026 package)

**Venue:** package P1 (instrument case study) · corpus also feeds Paper 2 Access  
**Pilot claim (locked):** loadable data-relocation addend error passes `insmod`, caught by predicates.

**Next delivery = raw data**, not scope negotiation.

## Pre-corpus / closed

| ID | Status | Evidence |
| --- | --- | --- |
| LP-PILOT-01 / 02 | **DONE** | Gate closed |
| **B1** pipeline baseline | **DONE** | `LP-CORPUS-01-pipeline/` |
| **C2** PLT32 reciprocal | **DONE** | `LP-CORPUS-02-func-sym/` |
| **C3** survivable redirect | **DONE** | `LP-CORPUS-03-survivable-sym/` + structural bind |
| **C5** under-inclusion | **DONE** | `LP-CORPUS-05-under-inclusion/` |

## Open — execute now

| ID | What | Blocker |
| --- | --- | --- |
| **C6** | kpatch `-O2`/`-Os` on PILOT-02 fix + P2/P3 | Runnable on v6.6.47 pin · `15-run-corpus-c6-kpatch-opt.sh` |
| **C4** | Full CVE stratification appendix (expand beyond n=20 sample) | Desk + lab · `cve-triage-table.md` |
| **Dirty Pipe** | Capstone CVE-2022-0847 compound case | Needs dedicated pin/plan — pre-6.6 · see `DIRTY-PIPE-CAPSTONE.md` |
| **C1** | `klp-build-upstream` vs kpatch | **Needs Linux 6.19+ re-pin** · Paper 2 primary |

## Paper prep (parallel)

| ID | What |
| --- | --- |
| P1 | Predicate scaling pattern |
| P2 | PILOT-02 vignette (forensic bundle exists) |
| P3 | Ground-truth cost table |

## Scripts

| ID | Script |
| --- | --- |
| B1 / C1 predicates | `11-run-corpus-c1-pipeline.sh` · `14-run-corpus-c1-predicates.sh` |
| C2 | `12-run-corpus-c2-func-sym.sh` |
| C3 | `13-run-corpus-c3-survivable-sym.sh` |
| C5 | `16-run-corpus-c5-under-inclusion.sh` |
| C6 | `15-run-corpus-c6-kpatch-opt.sh` |
