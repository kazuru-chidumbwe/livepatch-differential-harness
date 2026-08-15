# Dirty Pipe capstone — plan (CVE-2022-0847)

**Status:** OPEN · not started as livepatch micro-case  
**Class:** CAPSTONE (compound) — reserved after micro-cases validate harness  
**Triage:** `pilot/results/cve-triage-table.md`

## Why it does not drop onto v6.6.47 pin

Dirty Pipe is fixed **before** the package case-study pin (`v6.6.47`). Replaying the exploit fix as a livepatch against 6.6.47 is the wrong experiment (the bug is already absent). Capstone options:

| Option | Meaning | Cost |
| --- | --- | --- |
| **A** | Re-pin a **pre-fix** kernel (e.g. 5.16.x vulnerable) · build Dirty Pipe livepatch · full harness re-validation | Large — new `WORK_ROOT`, bzImage, handbuild |
| **B** | Treat Dirty Pipe as **Paper 2 / narrative** only on package — cite as motivation, no live QEMU | Cheap — honest |
| **C** | Synthetic compound case on 6.6.47 mimicking multi-site pipe/splice shape | Medium — not the real CVE |

**Sponsor ask (15 Aug):** run the corpus including Dirty Pipe. **Preferred path = Option A** on Lab Test Server when C6/C4 bandwidth allows; until then package manuscript must **not** claim Dirty Pipe results.

## Capstone acceptance criteria (Option A)

1. Vulnerable pin boots under QEMU with `CONFIG_LIVEPATCH=y`.  
2. Hand-built (or pipeline) livepatch applies the upstream fix symbols.  
3. Predicates encode the patch contract (pipe buffer flags / splice path) — **manual**.  
4. At least one loadable mutant class fails predicates with `INSMOD_RC=0` if applicable.  
5. Forensic pack under `pilot/results/LP-CORPUS-DIRTYPIPE/`.

## Immediate next (this session)

- [ ] Confirm lab disk for a second kernel tree (~2–4 GB).  
- [ ] Select vulnerable tag (document SHA).  
- [ ] Stub `pilot/cases/LP-CORPUS-DIRTYPIPE/` + handbuild skeleton.  
- [ ] Do **not** block package EM on capstone completion — package stays case-study instrument.
