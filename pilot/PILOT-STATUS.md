# Pilot execution status

**Updated:** 2026-07-10  
**Gate:** **CLOSED** (LP-PILOT-01 + LP-PILOT-02)

## Phase map

| Phase | Case | Status | Proves |
| --- | --- | --- | --- |
| Toolchain + gate process | **LP-PILOT-01** cmdline | **DONE** | Process buildable; load-time symbol check |
| Harness core claim | **LP-PILOT-02** version | **DONE** | Loadable **data-relocation** perturbation → `INSMOD_RC=0`, `P2_PASS=0` |
| Corpus | micro-cases → Dirty Pipe | **UNBLOCKED** | — |

## LP-PILOT-02 results

| Check | Result |
| --- | --- |
| Multi-reloc hand-build | PASS (PLT32 + 32S w/ addend `0x18`) |
| Good path | `P2_PASS=1`, `P3_PASS=1` |
| Loadable data-relocation perturbation | `INSMOD_RC=0`, **`P2_PASS=0`** |

Evidence: `pilot/results/LP-PILOT-02/`

## Worthiness

**PROCEED** — see [`PILOT-GATE-DELIVERABLES.md`](PILOT-GATE-DELIVERABLES.md).

## Sponsor follow-ups (2026-07-10)

| Item | Track | Status |
| --- | --- | --- |
| 9 Peer check | `pilot/outreach/` | **Sent 2026-07-10** — awaiting reply |
| 4 Benign variation | `10-benign-variation-pilot-02.sh` | **DONE** (`-O2`/`-Os`, P2/P3 pass) |
| 5 kcov | `09-kcov-pilot-02.sh` | **DONE** (1547 syscall-path BB hits) |
| 1 Forensic writeup | `results/LP-PILOT-02/forensic-writeup.md` | **DONE** (+ lab `disassembly-diff.txt`) |

Corpus items (2, 3, 7, 8) unchanged — see private programme `notes/sponsor-lp-pilot-scope-response.md`.
