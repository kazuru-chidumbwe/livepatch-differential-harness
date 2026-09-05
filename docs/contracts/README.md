# Minimal P2/P3 contract exemplars (operator-authored)

These YAML files instantiate `docs/PREDICATE-SCHEMA.md` for three published packs.
They document contracts; Stage B scripts remain the executable source of truth.

## Operator effort (illustrative, single-symbol marker packs)

| Step | Typical effort |
| --- | --- |
| Name post-patch observable (`MARKER` / dual-path files) | 15–45 min |
| Wire `case.env` + handbuild stub | 30–90 min (first time) |
| Known-good QEMU pass | 1–2 Stage B boots |
| Mutant / PRE triage (if claiming a class) | +30–60 min |

Single-symbol `/proc/version` marker contracts on a frozen pin are the low end (~1–2 h end-to-end once the pin/`bzImage` exists). Dual-path C5 and real upstream-function livepatches cost more.

Files:

- `contracts/LP-CORPUS-03-seqputs.yaml` — C3 structural + marker P2
- `contracts/LP-CVE-2023-52577.yaml` — INCLUDE synthetic PRE-gated P2/P3
- `contracts/LP-CORPUS-DIRTYPIPE.yaml` — Dirty Pipe-era marker (not `pipe_write`)
