# Corpus battle plan (sponsor agreement 2026-07-10)

**Pilot claim (locked):** loadable data-relocation addend error passes `insmod`, caught by predicates. No mission creep in abstract/intro.

**Next sponsor message = raw data**, not scope negotiation.

## Immediate — deliverables

### C2 — Function-symbol substitution twin

- [x] PLT32 swap `seq_printf` ↔ `seq_putc` — **DONE 2026-07-10** (`LP-CORPUS-02-func-sym/`)
- [x] Outcome: `INSMOD_RC=0`, **#PF at invoke**, `P2_PASS=0` (not load-time reject)

### C1 — kpatch-build vs klp on PILOT-02 fix

- [x] klp hand-build reference relocs captured
- [ ] kpatch-build — **blocked** (`not_installed`, `CONFIG_KPATCH` unset)

### C3 — Peer check

- [x] Sent 2026-07-10

### C4 — CVE stratification

- [ ] Full 6.1.y table Jan 2024–present; five-mechanism tags; appendix

### C5 — Under-inclusion hot/cold probe

- [ ] `__always_inline` case; klp_func set diff; ftrace cold path

### C6 — Cross-pipeline benign variation

- [ ] After C1 tools run: each pipeline × opt flag; P2/P3

## Paper (ongoing)

- [ ] Predicate library template
- [ ] Ground-truth cost log (time, iterations, lessons per case)

## Scripts

| ID | Script |
| --- | --- |
| C1 | `pilot/scripts/11-run-corpus-c1-pipeline.sh` |
| C2 | `pilot/scripts/12-run-corpus-c2-func-sym.sh` |
