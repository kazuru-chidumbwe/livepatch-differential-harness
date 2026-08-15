# Corpus phase checklist (4–8 weeks)

**Pilot status:** gate closed — existence proof only (loadable data-relocation).  
**Venue:** SoftwareX P1 (instrument) · corpus also feeds Paper 2.  
**Updated:** 2026-08-15 evening (SoftX restore · corpus resume)

## Immediate (weeks 1–2) — pre-corpus / closed

- [x] **B1** kpatch-build vs hand-build klp on PILOT-02 fix — relocs, disasm, P2/P3 (`LP-CORPUS-01-pipeline/`)
- [x] **C2** Function-symbol substitution — DONE
- [x] **C3** Survivable redirect — DONE; verified `C3-DATA-PACK.md` + structural bind
- [x] **C5** Under-inclusion probe — DONE

## Near-term (weeks 2–6) — open

- [ ] **C6** kpatch `-O2`/`-Os` per PILOT-02 fix (runnable on v6.6.47) — `15-run-corpus-c6-kpatch-opt.sh`
- [ ] **C4** Full CVE stratification — expand `cve-triage-table.md` beyond n=20 sample
- [ ] **Dirty Pipe** capstone — see `DIRTY-PIPE-CAPSTONE.md` (needs pre-fix pin)
- [ ] **C1** True cross-pipeline: `klp-build-upstream` vs kpatch (**Paper 2 — 6.19+ pin**)

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
