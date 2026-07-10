# Corpus phase checklist (4–8 weeks)

**Pilot status:** gate closed — existence proof only (loadable data-relocation).  
**Paper status:** measurement study not started until items below produce data.

## Immediate (weeks 1–2)

- [ ] **C1** kpatch-build vs klp-build on PILOT-02 fix — relocs, disasm, P2/P3; pin versions/commands
- [ ] **C2** Function-symbol substitution prototype — same-signature wrong callee; `insmod` + predicate outcome
- [ ] **C3** Peer check sent + replies logged (`pilot/outreach/`)

## Near-term (weeks 2–6)

- [ ] **C4** Full 6.1.y CVE stratification (expand n=20) — appendix table
- [ ] **C5** Under-inclusion probe — inline hot/cold, klp_func set diff, ftrace cold path
- [ ] **C6** First real CVE corpus case (mechanism-1) — includes C1/C2 on production fix

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
