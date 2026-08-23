# Corpus phase checklist (4–8 weeks)

**Pilot status:** gate closed — existence proof only (loadable data-relocation).  
**Venue:** package P1 (instrument) · corpus also feeds Paper 2.  
**Updated:** 2026-08-16 (C6 + Dirty Pipe Option A QEMU package closed · packs synced)

## Immediate (weeks 1–2) — pre-corpus / closed

- [x] **B1** kpatch-build vs hand-build klp on PILOT-02 fix — relocs, disasm, P2/P3 (`LP-CORPUS-01-pipeline/`)
- [x] **C2** Function-symbol substitution — DONE
- [x] **C3** Survivable redirect — DONE; verified `C3-DATA-PACK.md` + structural bind
- [x] **C5** Under-inclusion probe — DONE

## Near-term (weeks 2–6) — package tonight bar

- [x] **C6** kpatch `-O2`/`-Os` — **CLOSED** · `C6_KPATCH_OPT_DONE` · both P2; `P3_PASS=1` (v0.1.4 contract); `P3_ENABLED_ZERO` diagnostic
- [x] **C4** package appendix stratification — **CLOSED 15 Aug evening** · `cve-triage-table.md` (35 rows)
- [x] **Dirty Pipe** package Option A QEMU — **CLOSED 16 Aug** · `DIRTYPIPE_QEMU_DONE` · `pilot/results/LP-CORPUS-DIRTYPIPE/` · INSMOD=0 P2=1 P3=0
- [x] **C1** package disposition — **CLOSED via B1** · true `klp-build-upstream` = Paper 2 · `C1-package-DISPOSITION-2026-08-15.md`

## Paper prep (parallel)

- [x] **P1** Predicate scaling pattern (package §2.3)
- [x] **P2** PILOT-02 vignette (package §3.2)
- [x] **P3** Ground-truth cost table (package §3.6)

## Mechanism scorecard (update as cases land)

| # | Mechanism | Pilot | Corpus |
| --- | --- | --- | --- |
| 1 | Relocation / weak-symbol | Data addend only | Code substitution + cross-tool |
| 2 | Inlining scope | — | Under-inclusion probe **DONE** |
| 3 | Jump-label | — | Stratification-driven |
| 4 | Optimization / pipeline | Hand-build -O2/-Os | kpatch C6 **DONE** (P2 on -O2/-Os) |
| 5 | CRC / symver | — | When class warrants |
