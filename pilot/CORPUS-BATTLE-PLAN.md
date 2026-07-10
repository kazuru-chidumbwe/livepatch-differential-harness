# Corpus battle plan (sponsor agreement 2026-07-10)

**Pilot claim (locked):** loadable data-relocation addend error passes `insmod`, caught by predicates. No mission creep in abstract/intro.

**Next sponsor message = raw data**, not scope negotiation.

## Immediate — deliverables

### C2 — Function-symbol substitution (reciprocal PLT32 swap)

- [x] **DONE** — `INSMOD_RC=0`, **#PF** at invoke, `P2_PASS=0`
- [x] Forensic: `LP-CORPUS-02-func-sym/forensic-writeup.md`

### C3 — Survivable function redirect (one-way seq_puts → seq_putc)

- [x] **DONE 2026-07-10** — `INSMOD_RC=0`, **silent**, `P2_PASS=0` — code-relocation twin of PILOT-02

### C1 — kpatch-build vs klp on PILOT-02 fix

- [x] kpatch-build **installed** on lab (`/usr/local/bin/kpatch-build`)
- [ ] `CONFIG_KPATCH=y` kernel rebuild **in flight**
- [ ] Run kpatch-build + predicate compare vs hand-build klp

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
