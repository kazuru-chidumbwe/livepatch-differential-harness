# Dirty Pipe SoftX disposition — closed 16 Aug 2026

**CVE:** CVE-2022-0847  
**Venue:** SoftwareX P1 (this paper)  
**Lock:** Full **Option A QEMU** is SoftX — not Paper 2.  
**Status:** **CLOSED** · lab pack + local sync 16 Aug

---

## SoftX bar (Option A)

| SoftX requirement | Status | Evidence |
| --- | --- | --- |
| Capstone class in triage | **DONE** | `cve-triage-table.md` CAPSTONE row |
| Vulnerable pin locked | **DONE** | `v5.16.10` @ `528cecfa5af09631f0589efe9eacbd543c8c9db1` |
| Lab tree | **DONE** | `/opt/atlas/livepatch-corpus/linux-dirtypipe` |
| Case + handbuild | **DONE** | `pilot/cases/` · `pilot/handbuild/LP-CORPUS-DIRTYPIPE/` |
| Separate pin (not v6.6.47) | **DONE** | Wrong experiment on SoftX primary pin |
| **bzImage** boots with livepatch | **DONE** | `DIRTYPIPE_BZ_DONE` · SHA-256 in `pin.txt` |
| **Handbuild** loadable | **DONE** | `INSMOD_RC=0` · `livepatch-dirtypipe.ko` |
| **QEMU predicates** | **DONE** | `P2_PASS=1` · `P3_PASS=0` · `DIRTYPIPE_QEMU_DONE` |
| Forensic pack synced | **DONE** | `pilot/results/LP-CORPUS-DIRTYPIPE/` |

| SoftX must **not** claim | Why |
| --- | --- |
| Production / industry prevalence | Rates = Paper 2 |
| Compound-case throughput rates | One Option A path ≠ corpus rate |
| Dirty Pipe fix on v6.6.47 | Wrong pin |

---

## Paper 2 (not Dirty Pipe QEMU)

1. True `klp-build-upstream` C1 on linux-c1-619.  
2. INCLUDE shortlist / stratified rates.  
3. Prevalence / production measurement.
