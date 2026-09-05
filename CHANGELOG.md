## [Unreleased]

## [0.2.2] — 2026-09-05

### Added

- `docs/STRUCTURAL-ORACLE.md` — PLT32 bind algorithm, FP policy, type coverage.
- `docs/contracts/` — YAML exemplars (C3, INCLUDE S-52577, Dirty Pipe marker) + operator-effort notes.
- `pilot/scripts/29-stanford-lab-suite.sh` — Host B structural recheck, timed TCG P2/P3, benign aggregation, KVM absence note.
- `pilot/results/STANFORD-LAB-20260905T002910Z/` — wall-clock + SUMMARY (`STRUCTURAL_BIND_PASS=1`; three boots P2/P3 pass; KVM_ABSENT).
- `pilot/results/BENIGN-SUITE.md` — aggregated B1 / C6 / PILOT-02 benign controls.

### Changed

- `docs/ARCHITECTURE.md` — observables table + `QEMU_ACCEL` note.
- `docs/PREDICATE-SCHEMA.md` — points at contracts / structural oracle (package `v0.2.2`).
- `verify-plt32-binding.py` docstring documents algorithm steps.
- Zenodo version DOI **10.5281/zenodo.22313867** (concept **10.5281/zenodo.21958991**) wired in `docs/ZENODO.md` / `CITATION.cff` / `.zenodo.json`.

### Lab evidence (`v0.2.2` · Stanford suite · Host B `10.4.0.32`)

- TCG wall_sec: INCLUDE primary 26.698; Dirty Pipe 6.248; second-pin INCLUDE 6.573.
- `KVM_ABSENT=1` (no nested virt on Host B).
- Close: `STANFORD_LAB_DONE=20260905T002910Z`.

## [0.2.1] — 2026-09-03

### Added

- `pilot/scripts/28-run-second-pin-depth.sh` — second-pin depth on existing v6.1.119 bzImage.
- `pilot/results/LP-SECOND-PIN-v6.1.119/SECOND-PIN-DEPTH/` — two INCLUDE packs + C3 mutant class on v6.1.119.

### Lab evidence (`v0.2.1` · second-pin depth)

- Host `boma-test`: CVE-2023-52577 and CVE-2024-36904 PRE-gated P2/P3 pass on v6.1.119.
- C3 on v6.1.119: `STRUCTURAL_BIND_PASS=1`; good P2=1; perturb INSMOD=0 and P2=0.
- Close: `SECOND_PIN_DEPTH_DONE=2026-09-03T21:03:05Z`.

## [0.2.0] — 2026-09-03

### Added

- `pilot/scripts/pre-revert-scan.py` — PRE(A) static revert-soundness scan (`SOUND` / `OUT_OF_SCOPE`).
- `pilot/scripts/test_pre_revert_scan.py` — unit tests (mocked symbols).
- `emit_pre_skip_p3` in `pilot/scripts/lib/klp-predicates.sh` — skip runtime P3 when PRE fails.
- CVE contract packs: `pilot/handbuild/LP-CVE-2023-52577/`, `LP-CVE-2024-36904/` plus case READMEs.
- lab scripts: `17-run-v020.sh`, `19-resume-dirtypipe-build.sh`, `21-run-dirtypipe-pregated.sh`, `22-rerun-dirtypipe-pregated.sh`.
- Lab runbook: `pilot/results/LAB-RUNBOOK-V020-2026-09-03.md`.
- Dirty Pipe close marker `pilot/results/LP-CORPUS-DIRTYPIPE/DIRTYPIPE_PREGATED_DONE.txt` (`2026-09-03T19:55:28Z`).

### Changed

- Predicate schema documents Stage A PRE gating (prior cite pin).
- Dirty Pipe handbuild `Makefile` pins `M=` via `MAKEFILE_LIST` so a parent kernel `cd` / exported `CURDIR` cannot rebuild the v5.16.10 tree as a module.

### Lab evidence (`v0.2.0` cite pin · full pipeline)

- Host `boma-test`: six INCLUDE CVE packs, Dirty Pipe, v6.1.119 second pin — PRE-gated P2/P3 pass.
- PRE population N=24 (23 SOUND, 1 OUT_OF_SCOPE).
- `klp-build` present on cloned v6.19; equivalence matrix deferred.
- Dirty Pipe bzImage SHA-256 `dccbb329…`; second-pin bzImage `2fa03847…`.
- Close: `FULL_PIPELINE_DONE=2026-09-03T20:25:47Z`.

## [0.1.4] — 2026-08-23

### Changed

- operator-facing `P3_PASS` = `P3_CONTRACT_PASS` = transition complete ∧ baseline
  observed. `P3_ENABLED_ZERO` remains diagnostic (sysfs may lag functional revert).
- Refreshed C6 predicate packs under the new composite; cite pin → `v0.1.4`.

## [0.1.3] — 2026-08-23

### Added

- `docs/PREDICATE-SCHEMA.md` — compact YAML sketch for per-case P2/P3 contracts.
- `pilot/scripts/lib/klp-predicates.sh` — hardened P3 revert helpers (`P3_*`, `KLP_*`).
- `pilot/scripts/lib/check-init-no-klp-glob.sh` — host guard against `livepatch/*/enabled` glob redirects.

### Changed

- C5/C6 and Stage B generators source `klp-predicates.sh`; C5 no longer uses naive sysfs glob.
- Refreshed C6 hardened P3 packs (`-O2`/`-Os`): `P2_PASS=1`, `P3_PASS=0` with
  `P3_ENABLED_ZERO=0` (not glob failure); both modules and serials under
  `pilot/results/LP-CORPUS-06-kpatch-opt/`.
- package cite pin → `v0.1.3`.
- `RELEASE_MANIFEST.yaml` digests and QEMU version notes aligned to cite tip.

## [0.1.2] — 2026-08-16

- package corpus closeout packs (C6 + Dirty Pipe Option A QEMU).
- `RELEASE_MANIFEST.yaml` + `pilot/results/EVALUATION-MATRIX.md` (RQ / counts / overhead).
- Cite pin `v0.1.2`; Zenodo metadata notes package (GitHub remains C2).
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Case-study pins (`pin-lp1-*`) remain valid reproducibility anchors for the
v6.6.47 freeze. Prefer **SemVer** (`vX.Y.Z`) for package C1 / CITATION.cff; see
[`docs/TAGS.md`](docs/TAGS.md). Zenodo: [`docs/ZENODO.md`](docs/ZENODO.md).

## [0.1.1] — 2026-08-15

### Added

- Structural bind evidence for C3 (`STRUCTURAL_BIND_PASS`) refresh under
  `pilot/results/LP-CORPUS-03-survivable-sym/`.
- Stage A Stage A from-source prove note (`pilot/results/STAGE-A-FROM-SOURCE-PROVE.md`).
- `.zenodo.json` + `docs/ZENODO.md` for package reproducible capsule (GitHub C2 · Zenodo after mint).

### Changed

- C3 QEMU script timeout / klp force path for reliable P2 good=1 / perturb=0.
- `CITATION.cff` / README pin → package primary (was package-only wording).

## [0.1.0] — 2026-07-27

### Added

- First SemVer release for package / package citation (`CITATION.cff` version `0.1.0`).
- package dated pin `pin-lp1-20260725c` (`386226e`) remains the case-study freeze.
- `CHANGELOG.md` and SemVer tag policy in `docs/TAGS.md`.

[0.1.4]: https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.4
[0.1.3]: https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.3
[0.1.2]: https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.2
[0.1.1]: https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.1
[0.1.0]: https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.0
