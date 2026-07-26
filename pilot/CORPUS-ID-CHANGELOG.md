# Corpus case ID changelog

Tracks renames so paper text, repo history, and artifact directories stay legible when diffed.

---

## 2026-07-10 — B1 vs C1 split (Paper v0.4 rescope)

### Problem

The label **C1** was used for two different experiments across working documents:

| Period | "C1" meant | Status |
| --- | --- | --- |
| Early corpus plan | `klp-build-upstream` vs `kpatch-build` on same patch | **Blocked** — needs Linux 6.19+ |
| Jul 2026 execution | hand-build `klp_patch` reference vs `kpatch-build` on PILOT-02 fix | **Done** — was mislabeled C1 in scripts/results |

Without an explicit trail, repo history could read as quietly substituting an achievable comparison for the blocked one.

### Resolution

| Paper label | Meaning | Artifact directory (unchanged) |
| --- | --- | --- |
| **B1** | hand-build klp reference vs `kpatch-build` on `LP-PILOT-02-version.patch` | `pilot/results/LP-CORPUS-01-pipeline/` |
| **C1** | `klp-build-upstream` vs `kpatch-build` (true cross-pipeline) | Paper 2 — blocked on v6.6.47 pin |

### Files updated (labels/comments, not directory renames)

- `pilot/scripts/11-run-corpus-c1-pipeline.sh` — header notes B1
- `pilot/scripts/14-run-corpus-c1-predicates.sh` — B1 predicate transcript
- `pilot/docker/run-all.sh` — "B1 pipeline baseline"
- `pilot/CORPUS-BATTLE-PLAN.md`, `pilot/CORPUS-CHECKLIST.md`
- LivepatchDiff / paper case-ID map (private programme pack; not in this repo)
- *(removed 2026-07-26)* former `pilot/results/SPONSOR-DATA-PACK-2026-07-10.md` — B1 verdict prose; science remains under `LP-CORPUS-*`

### Git commits

- `2f3cd07` — Complete C1 cross-pipeline (historical message; run was B1 content in `LP-CORPUS-01-pipeline/`)
- `7ce6e2a` — Paper v0.4 honesty rescope; B1 vs C1 naming in docs/scripts
- *(this changelog)* — explicit rename documentation for history auditors

### Rule going forward

- **B1** = reference-vs-pipeline baseline on current pin  
- **C1** = production pipeline pair on same pin (Paper 2, 6.19+)  
- Do not reuse **C1** for hand-build vs kpatch in new commits or paper text
