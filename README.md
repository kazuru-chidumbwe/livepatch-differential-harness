# Livepatch Differential Harness

Differential test harness for Linux livepatch **build pipelines** (LivepatchDiff instrument name: **LivepatchDiff**). Identical source patches are built with multiple tools under a pinned kernel commit; outputs are compared for **trace-equivalence** using hand-built `klp_patch` reference modules, ELF normalization, and per-case predicate suites.

**Venue:** package (tool paper) — Atlas pack [`softwarex-manuscript/`](../../softwarex-manuscript/)  
**Local-only until push gate:** public LivepatchDiff pin gate (see README)  
**Status:** pilot **gate closed** (LP-PILOT-01 toolchain + LP-PILOT-02 data-relocation claim). Corpus unblocked.

**Before public push:** `bash scripts/pre-push-hygiene.sh`

**Public release:** LivepatchDiff EM needs a **public** GitHub pin. Until then this tree stays local (and on test-server). LP01 blog ships only after LivepatchDiff accept.

---

## Pilot phases (honest labeling)

| Phase | Case | What it proves |
| --- | --- | --- |
| **Toolchain validation** | LP-PILOT-01 (`cmdline_proc_show`) | Hand-build, QEMU, revert, and **load-time** perturbation (wrong symbol → `insmod` fail) |
| **Harness core claim** | LP-PILOT-02 (`version_proc_show`) | **Loadable** divergence caught by **behavioral predicates** (rodata addend perturbation, `insmod` OK) |
| **Corpus** | CVE micro-cases → Dirty Pipe capstone | After gate close only |

---

## Build pipelines under test

Use **qualified names** in papers and manifests — never bare `klp-build`.

| ID | Tool | Role |
| --- | --- | --- |
| `kpatch-build` | dynup/kpatch `kpatch-build` | Legacy binary-diff pipeline (maintenance mode) |
| `klp-build-upstream` | `scripts/livepatch/klp-build` in Linux **6.19+** | In-tree objtool successor |
| `SUSE-klp-build` | [SUSE/klp-build](https://github.com/SUSE/klp-build) + `klp-ccp` | Vendor orchestration; qualitative unless IBS-reproduced |
| `kernel-livepatch-packaging` | SUSE `kernel-livepatch` scripts | **Excluded** — RPM/patch aggregation wrapper, not a builder |

Hand-built `klp_patch` modules are **ground truth**, not a competing pipeline.

See [`docs/MEASUREMENT-PROTOCOL.md`](docs/MEASUREMENT-PROTOCOL.md) and [`pilot/results/kgraft-patch-pipeline-check.md`](pilot/results/kgraft-patch-pipeline-check.md).

---

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

---

## Layout

```
pilot/            Pilot cases, hand-build, results (gate evidence)
patches/          Corpus (post-gate)
pipelines/        Per-tool wrappers (`kpatch-build`, `klp-build-upstream`, …)
normalize/        ELF + dmesg canonicalizers
docs/             MEASUREMENT-PROTOCOL, PROVENANCE
```

---

## License

MIT — see [LICENSE](LICENSE).
