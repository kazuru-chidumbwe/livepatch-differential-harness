# Evaluation matrix (pilot corpus) —  v0.2.0 track

**Pin:** Linux v6.6.47 (`4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7`) unless noted.  
**Scope:** controlled instrument evaluation — not prevalence.  
**Cite pin target:** `v0.2.0` (PRE-gated P3; **not tagged yet**).  
**Venue:**  P1 · package Plan B  
**Lab close:** `DIRTYPIPE__DONE=2026-09-03T19:55:28Z` on `boma-test` via `17-run-eisej-v020.sh`.  

**Research questions ()**

| RQ | Question | Bounded answer |
| --- | --- | --- |
| **RQ1** PRE | Can static PRE(A) classify revert-soundness eligibility from a built `.ko`? | Yes — `SOUND` vs `OUT_OF_SCOPE`(+trigger) via `pre-revert-scan.py` |
| **RQ2** Detection | Can LivepatchDiff detect targeted fault classes when modules remain loadable? | Yes for M1/M2 mutants in this corpus |
| **RQ3** Revert | When PRE=`SOUND`, does hardened P3 close without open-oracle language? | C6, both INCLUDE CVE contract packs, and Dirty Pipe PRE-gated re-run: P3_PASS=1 |
| **RQ4** Depth | Do ≥2 INCLUDE CVE micro-cases replay on the pin? | **Yes (contract packs)** — CVE-2023-52577 and CVE-2024-36904 on v6.6.47 |

## Mutation / case matrix

| Case | Fault class | Mutation / build | Load (`INSMOD_RC`) | PRE | Static oracle | P2 | P3 | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PILOT-02 good | — | none | 0 | SOUND* | n/a | 1 | 1 | baseline |
| PILOT-02 mutant | M1 rodata | addend swap | 0 | SOUND* | n/a | 0 | — | detected |
| C2 | M1 PLT32 | `seq_printf`↔`seq_putc` | 0 | SOUND* | n/a | 0 | — | detected |
| C3 good | — | none | 0 | SOUND* | n/a | 1 | — | baseline |
| C3 mutant | M1 PLT32 | `seq_puts`→`seq_putc` | 0 | SOUND* | 1 | 0 | — | detected |
| C5 | M2 under-incl. | cold path omitted | 0 | SOUND* | n/a | dual-path | — | detected |
| B1 hand / kpatch | M4 benign | pipeline pair | 0 / 0 | SOUND* | n/a | 1 / 1 | 1 / 1 | benign OK |
| C6 `-O2` | M4 opt | kpatch rebuild | 0 | SOUND* | n/a | 1 | 1 | contract P3 |
| C6 `-Os` | M4 opt | kpatch rebuild | 0 | SOUND* | n/a | 1 | 1 | contract P3 |
| Dirty Pipe (`v5.16.10`) | pin smoke | marker livepatch | 0 | SOUND | n/a | 1 | 1 | `DIRTYPIPE__DONE` 2026-09-03T19:55:28Z (`boma-test`; bzImage `dccbb329…`) |
| CVE-2023-52577 | INCLUDE | hand-build contract | 0 | SOUND | n/a | 1 | 1 | executed 2026-09-03 (`boma-test`) |
| CVE-2024-36904 | INCLUDE | hand-build contract | 0 | SOUND | n/a | 1 | 1 | executed 2026-09-03 (`boma-test`) |

\*PRE column: expected `SOUND` for handbuilt samples without shadow/callbacks; confirm with `pre-revert-scan.py` on cite-pin rebuild.

## Counts (this corpus only)

| Metric | Count |
| --- | --- |
| Known-good / baseline artifacts exercised | 6 |
| Targeted mutants generated | 4 (PILOT-02, C2, C3, C5) |
| Mutants that remained loadable | 4 / 4 |
| Loader-invisible mutants detected by ≥1 contract | 4 / 4 |
| Benign pipeline pair (B1) with matching P2/P3 | 1 |
| Opt-level rebuilds with P2_PASS=1 | 2 / 2 |
| C6 runs with P3_PASS=1 | 2 / 2 (v0.1.4 contract) |
| INCLUDE CVE micro-cases executed | **2 / 2** (contract packs on v6.6.47; not field reproductions) |
| Dirty Pipe PRE-gated P3 | **done** (`DIRTYPIPE__DONE`; `PRE_CLASS=SOUND`, P3_PASS=1 on rebuilt v5.16.10) |

See `LAB-RUNBOOK--V020-2026-09-03.md`.  packs on 3 Sep 2026 ran on `boma-test` (`172.19.4.243`), not Tailscale Lab Test Server.

**Do not** report these as production rates.

## Negative / benign controls present

| Control | Role |
| --- | --- |
| Known-good modules before mutation | True negative for P2 |
| B1 hand vs kpatch without mutation | Benign layout control |
| C6 `-O2`/`-Os` without mutation | Benign opt-level control |
| Loader-rejecting mutants | Out of package “loader-invisible” claim scope (documented separately where run) |

## Overhead (Lab Test Server–class; illustrative)

| Step | Typical | Observed notes |
| --- | --- | --- |
| Kernel pin + `bzImage` | hours (once / tree) | Dominates wall clock |
| Handbuild / `kpatch-build` `.ko` | minutes / case | Stage A or host |
| Mutation + structural check | seconds | Scripted |
| QEMU boot → P2/P3 → poweroff | ≤120 s timeout / run (allows ≤30 s transition poll) | C3 serial shows ~47–55 s to patching complete under lab defconfig |
| Host | x86-64 · Docker · QEMU · ≥8 GiB RAM recommended | Guest-only module load |

Median/range over many machines is **not** claimed; figures are single-lab illustrative.
