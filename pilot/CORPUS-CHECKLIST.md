# Corpus phase checklist (4–8 weeks)

**Pilot status:** gate closed — existence proof only (loadable data-relocation).  
**Paper status:** measurement study not started until items below produce data.

## Immediate (weeks 1–2)

- [x] **B1** kpatch-build vs hand-build klp on PILOT-02 fix — relocs, disasm, P2/P3 (`LP-CORPUS-01-pipeline/`)
- [x] **C2** Function-symbol substitution — DONE
- [x] **C3** Survivable redirect — DONE; verified `C3-DATA-PACK.md`
- [x] **C5** Under-inclusion probe — DONE

## Near-term (weeks 2–6)

- [ ] **C1** True cross-pipeline: `klp-build-upstream` vs kpatch (Paper 2 — 6.19+ pin)
- [ ] **C4** Full 6.1.y CVE stratification — appendix table
- [ ] **C6** kpatch `-O2`/`-Os` per CVE (Paper 2)

## Paper prep (parallel)

- [ ] **P1** Predicate scaling pattern (methods §5 — beyond marker checks)
- [ ] **P2** PILOT-02 vignette (forensic bundle)
- [ ] **P3** Ground-truth cost table (iterations, time, failures per case)

## Mechanism scorecard (update as cases land)

| # | Mechanism | Pilot | Corpus |
| --- | --- | --- | --- |
| 1 | Relocation / weak-symbol | Data addend only | Code substitution + cross-tool |
| 2 | Inlining scope | — | Under-inclusion probe |
| 3 | Jump-label | — | Stratification-driven |
| 4 | Optimization / pipeline | Hand-build -O2/-Os | kpatch vs klp |
| 5 | CRC / symver | — | When class warrants |
