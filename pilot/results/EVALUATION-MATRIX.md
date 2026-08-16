# SoftX evaluation matrix (pilot corpus)

**Pin:** Linux v6.6.47 (`4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7`) unless noted.  
**Scope:** controlled case study — not prevalence.  
**Research questions**

| RQ | Question | SoftX answer (bounded) |
| --- | --- | --- |
| **RQ1** Detection | Can LivepatchDiff detect each targeted fault class when the mutated module remains loadable? | Yes for M1 rodata, M1 PLT32 silent (C3), M2 under-inclusion (C5) in this corpus |
| **RQ2** Oracle agreement | Do static binding checks and runtime predicates agree on intended mutant classifications? | C3: `STRUCTURAL_BIND_PASS=1` and `P2_PASS=0` agree on detection |
| **RQ3** Robustness | Do predicates tolerate benign hand-build vs `kpatch-build` and `-O2`/`-Os`? | B1: both pass P2/P3; C6: both pass P2; P3 fails (marker-revert limitation) |
| **RQ4** Reproducibility | Can an operator replay classifications from the pinned Docker/QEMU pack? | Replay scripts + `RELEASE_MANIFEST.yaml` digests; QEMU guest only |

## Mutation / case matrix

| Case | Fault class | Mutation / build | Load (`INSMOD_RC`) | Static oracle | P2 | P3 | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PILOT-02 good | — | none | 0 | n/a | 1 | 1 | baseline |
| PILOT-02 mutant | M1 rodata | addend swap | 0 | n/a | 0 | — | detected |
| C2 | M1 PLT32 | `seq_printf`↔`seq_putc` | 0 | n/a | 0 | — | detected (faulting) |
| C3 good | — | none | 0 | n/a | 1 | — | baseline |
| C3 mutant | M1 PLT32 | `seq_puts`→`seq_putc` | 0 | 1 | 0 | — | detected |
| C5 | M2 under-incl. | cold path omitted | 0 | n/a | dual-path | — | detected |
| B1 hand / kpatch | M4 benign | pipeline pair | 0 / 0 | n/a | 1 / 1 | 1 / 1 | benign OK |
| C6 `-O2` | M4 opt | kpatch rebuild | 0 | n/a | 1 | 0 | P2 OK; P3 limitation |
| C6 `-Os` | M4 opt | kpatch rebuild | 0 | n/a | 1 | 0 | P2 OK; P3 limitation |
| Dirty Pipe (`v5.16.10`) | pin smoke | marker livepatch | 0 | n/a | 1 | 0 | separate-pin P2; P3 limitation |

## Counts (this corpus only)

| Metric | Count |
| --- | --- |
| Known-good / baseline artifacts exercised | 6 |
| Targeted mutants generated | 4 (PILOT-02, C2, C3, C5) |
| Mutants that remained loadable | 4 / 4 |
| Loader-invisible mutants detected by ≥1 contract | 4 / 4 |
| Benign pipeline pair (B1) with matching P2/P3 | 1 |
| Opt-level rebuilds with P2_PASS=1 | 2 / 2 |
| C6 / Dirty Pipe runs with P3_PASS=1 | 0 (known marker-revert limitation) |

**Do not** report these as production rates.

## Negative / benign controls present

| Control | Role |
| --- | --- |
| Known-good modules before mutation | True negative for P2 |
| B1 hand vs kpatch without mutation | Benign layout control |
| C6 `-O2`/`-Os` without mutation | Benign opt-level control |
| Loader-rejecting mutants | Out of SoftX “loader-invisible” claim scope (documented separately where run) |

## Overhead (Lab Test Server–class; illustrative)

| Step | Typical | Observed notes |
| --- | --- | --- |
| Kernel pin + `bzImage` | hours (once / tree) | Dominates wall clock |
| Handbuild / `kpatch-build` `.ko` | minutes / case | Stage A or host |
| Mutation + structural check | seconds | Scripted |
| QEMU boot → P2/P3 → poweroff | ≤90 s timeout / run | C3 serial shows ~47–55 s to patching complete under lab defconfig |
| Host | x86-64 · Docker · QEMU · ≥8 GiB RAM recommended | Guest-only module load |

Median/range over many machines is **not** claimed; figures are single-lab illustrative.
