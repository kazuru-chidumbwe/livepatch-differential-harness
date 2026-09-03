# Livepatch Differential Harness

Test harness for Linux livepatch build pipelines (instrument name LivepatchDiff). Under a pinned kernel commit, identical source patches can be built with more than one tool. Outputs are compared for trace-equivalence (matching operator-declared structural and runtime predicates on the resulting `.ko`, not bit-identical binaries) using hand-built `klp_patch` reference modules, ELF normalization, and per-case predicate suites.

Public pin: https://github.com/kazuru-chidumbwe/livepatch-differential-harness  
Cite pin `v0.2.1` (prior `v0.2.0` / `v0.1.4`). See `CITATION.cff`, [`docs/TAGS.md`](docs/TAGS.md), [`CHANGELOG.md`](CHANGELOG.md), [`docs/ZENODO.md`](docs/ZENODO.md), [`RELEASE_MANIFEST.yaml`](RELEASE_MANIFEST.yaml).

Status. Research-article evaluation on Linux v6.6.47, Dirty Pipe v5.16.10, and second-pin v6.1.119. Proof-of-concept corpus on fixed pins. Not a stratified prevalence study and not a claim of generalization across kernel versions or configs. Historical freeze tag `pin-lp1-20260725c` remains a reproducibility anchor.

Operator docs: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), Docker stages in [`pilot/docker/README.md`](pilot/docker/README.md), evaluation in [`pilot/results/EVALUATION-MATRIX.md`](pilot/results/EVALUATION-MATRIX.md), lab notes in [`pilot/results/LAB-RUNBOOK-V020-2026-09-03.md`](pilot/results/LAB-RUNBOOK-V020-2026-09-03.md).

This public tree does not name target journals or publishers. Cite SemVer tags only.

Pin attribution. Mutant / B1 / C6 → `v0.1.4`. INCLUDE×6, Dirty Pipe PRE-gated, v6.1.119 smoke, PRE N=24 → `v0.2.0`. Second-pin depth (2 INCLUDE + C3 on v6.1.119) → `v0.2.1`. Published cross-toolchain packs compare hand vs `kpatch-build` only. The `klp-build` (6.19+) equivalence matrix is deferred.

Before push: `bash scripts/pre-push-hygiene.sh`

## Pilot phases

| Phase | Case | What it proves |
| --- | --- | --- |
| Toolchain validation | LP-PILOT-01 (`cmdline_proc_show`) | Hand-build, QEMU, revert, and load-time perturbation (wrong symbol → `insmod` fail) |
| Harness core claim | LP-PILOT-02 (`version_proc_show`) | Loadable divergence caught by behavioral predicates (rodata addend perturbation, `insmod` OK) |
| Corpus | CVE micro-cases → Dirty Pipe capstone | After gate close only |

## Build pipelines under test

Use qualified names in papers and manifests. Prefer `klp-build-upstream` or `scripts/livepatch/klp-build` over a bare `klp-build` token when the source tree matters.

| ID | Tool | Role |
| --- | --- | --- |
| `kpatch-build` | dynup/kpatch `kpatch-build` | Legacy binary-diff pipeline (maintenance mode) |
| `klp-build-upstream` | `scripts/livepatch/klp-build` in Linux 6.19+ | In-tree objtool successor |
| `SUSE-klp-build` | [SUSE/klp-build](https://github.com/SUSE/klp-build) + `klp-ccp` | Vendor orchestration; qualitative unless IBS-reproduced |
| `kernel-livepatch-packaging` | SUSE `kernel-livepatch` scripts | Excluded. RPM/patch aggregation wrapper, not a builder |

Hand-built `klp_patch` modules are ground truth, not a competing pipeline.

See [`docs/MEASUREMENT-PROTOCOL.md`](docs/MEASUREMENT-PROTOCOL.md) and [`pilot/results/kgraft-patch-pipeline-check.md`](pilot/results/kgraft-patch-pipeline-check.md).

## Quick start

```bash
bash scripts/bootstrap-env.sh
make smoke
# Lab pilot (Linux + QEMU):
bash pilot/scripts/00-install-host-deps.sh
bash pilot/scripts/01-fetch-kernel.sh
bash pilot/scripts/02-config-kernel.sh
bash pilot/scripts/03-build-kernel.sh
bash pilot/scripts/04-handbuild.sh          # LP-PILOT-01
bash pilot/scripts/08-run-lp-pilot-02.sh    # LP-PILOT-02
```

## Layout

```
pilot/            Pilot cases, hand-build, results (gate evidence)
patches/          Corpus (post-gate)
pipelines/        Per-tool wrappers (`kpatch-build`, `klp-build-upstream`, …)
normalize/        ELF + dmesg canonicalizers
docs/             MEASUREMENT-PROTOCOL, PROVENANCE
```

## License

MIT. See [LICENSE](LICENSE).
