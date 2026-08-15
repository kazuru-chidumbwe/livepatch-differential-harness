# Corpus phase checklist (4–8 weeks)

**Pilot status:** gate closed — existence proof only (loadable data-relocation).  
**Venue:** package P1 (instrument) · corpus also feeds Paper 2.  
**Updated:** 2026-08-15 evening (package restore · corpus resume)

## Immediate (weeks 1–2) — pre-corpus / closed

- [x] **B1** kpatch-build vs hand-build klp on PILOT-02 fix — relocs, disasm, P2/P3 (`LP-CORPUS-01-pipeline/`)
- [x] **C2** Function-symbol substitution — DONE
- [x] **C3** Survivable redirect — DONE; verified `C3-DATA-PACK.md` + structural bind
- [x] **C5** Under-inclusion probe — DONE

## Near-term (weeks 2–6) — corpus closeout bar

- [ ] **C6** kpatch `-O2`/`-Os` — *IN FLIGHT on lab* · `15-run-corpus-c6-kpatch-opt.sh` (must finish tonight)
- [x] **C4** package appendix stratification — **CLOSED 15 Aug evening** · `cve-triage-table.md` (35 rows)
- [x] **Dirty Pipe** package appendix — **CLOSED** pin+skeleton · QEMU = Paper 2 · `DIRTYPIPE-PACKAGE-DISPOSITION-2026-08-15.md`
- [x] **C1** package disposition — **CLOSED via B1** · true `klp-build-upstream` = Paper 2 · `C1-DISPOSITION-DISPOSITION-2026-08-15.md`

## Paper prep (parallel)

- [ ] **P1** Predicate scaling pattern (methods §5 — beyond marker checks)
- [ ] **P2** PILOT-02 vignette (forensic bundle largely exists)
- [ ] **P3** Ground-truth cost table (iterations, time, failures per case)

## Mechanism scorecard (update as cases land)

| # | Mechanism | Pilot | Corpus |
| --- | --- | --- | --- |
| 1 | Relocation / weak-symbol | Data addend only | Code substitution + cross-tool |
| 2 | Inlining scope | — | Under-inclusion probe **DONE** |
| 3 | Jump-label | — | Stratification-driven |
| 4 | Optimization / pipeline | Hand-build -O2/-Os | kpatch vs klp · **C6 open** |
| 5 | CRC / symver | — | When class warrants |
