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
| **C6** | kpatch `-O2`/`-Os` | **CLOSED** 16 Aug · `LP-CORPUS-06-kpatch-opt/` |
| **C4** | CVE stratification appendix | **CLOSED** package · expand optional |
| **Dirty Pipe** | Capstone Option A QEMU | **CLOSED** package 16 Aug · `LP-CORPUS-DIRTYPIPE/` |
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
