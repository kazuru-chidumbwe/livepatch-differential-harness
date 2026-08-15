# C4 status — CVE stratification (15 Aug 2026)

**Open.** Bounded sample exists in `cve-triage-table.md` (n=20, window 2023-10→2024-12 on 6.6.y).

## Target for package / Paper 2

| Deliverable | package | Paper 2 |
| --- | --- | --- |
| Bounded sample + rules | **Enough** for instrument paper appendix pointer | Baseline |
| Full 6.1.y / 6.6.y enumeration | Nice-to-have appendix | **Required** for prevalence claims |
| INCLUDE micro-cases executed | Optional package depth | Required |

## Next lab actions

1. Export CVE-tagged commits from `linux-stable` for 6.6.y (shallow clone insufficient — deepen history or use NVD + stable queue).  
2. Re-annotate with five-mechanism tags.  
3. Pick next **INCLUDE** micro-case after C6 (candidates: CVE-2023-52577, CVE-2023-52578, CVE-2024-22705).

## Honest package claim

package may cite the **bounded sample table** and state full stratification is ongoing. Do not claim complete 6.1.y coverage until the table says so.
