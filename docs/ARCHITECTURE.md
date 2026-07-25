# LivepatchDiff architecture and reuse workflow

SoftwarX case-study pin: Linux **v6.6.47**. This document is the operator-facing API for adapting the harness beyond the illustrative corpus.

```
User inputs (per case)
    ↓
Build plane  — hand-build klp_patch (+ optional kpatch-build baseline)
    ↓
Mutate plane — loadable ELF relocation edits (optional)
    ↓
Static plane — relocation triage + structural bind checks
    ↓
Runtime plane — QEMU predicates (P2 / P3 / dual-path)
    ↓
Classify     — pass / diverge / inconclusive + evidence packs
```

## What a user must provide

| Input | Required? | Notes |
| --- | --- | --- |
| Kernel tree at pinned commit | Yes for build-from-source | `WORK_ROOT/linux` or mount at `/work/linux` |
| Case `case.env` | Yes | `PROC_FILE`, `MARKER`, pins |
| Patch / hand-build `.c` + `Makefile` | Yes | Under `pilot/handbuild/<case>/` |
| Predicate contract | Yes (manual) | What observable proves the fix? Encode as marker / dual-path checks |
| Mutation class (if testing loader gap) | Optional | M1–M2 exercised on this pin; M3/M5 discussion-only |

## What the harness generates automatically

| Output | Generator |
| --- | --- |
| `.ko` modules | `make` in handbuild dirs / pipeline wrappers |
| Loadable mutants | `perturb-*.py` |
| Relocation triage dumps | `readelf` / scripts under `pilot/scripts/` |
| **Structural PLT32 bind oracle** | `verify-plt32-binding.py` (C3 ground truth) |
| QEMU serial + `P2`/`P3`/`INSMOD_RC` lines | per-case `*-run-*.sh` |
| Evidence packs | `pilot/results/<case>/` |

## What stays manual (honest SoftwarX scope)

1. **Semantic predicate design** — P2/P3 are not synthesized from the patch diff. The user states the patch contract (e.g. “`/proc/version` must contain `MARKER` after patch; restore baseline after revert”).
2. **Under-inclusion path selection** — dual-path predicates require the user to name hot and cold observables; the harness does not discover them.
3. **Kernel / toolchain pins** — changing the pin requires rebuild and re-validation; modules are not portable across versions.
4. **Predicate sufficiency** — there is no completeness proof. Sufficiency rule used here: predicates must (a) pass on known-good artifacts, (b) fail on injected mutants of the claimed class, (c) tolerate documented benign codegen pairs (B1 / `-O2`/`-Os` where exercised).

## Predicate layers (do not conflate)

| Layer | Example | Role |
| --- | --- | --- |
| **Structural** | `STRUCTURAL_BIND_PASS` for C3 | Proves wrong relocation binding; layout-independent |
| **Semantic / behavioral** | `P2` marker grep | Proves patch contract; must not rely on coincidental corrupt glyphs |
| **Operational** | `INSMOD_RC`, dmesg silence | Separates loader-accepted faults from load failures |

For C3, structural bind is **required** ground truth. Runtime glyphs under `nokaslr` are illustrative side-effects only.

## Adapting to a new patch (minimal workflow)

1. Add `pilot/cases/<id>/case.env` with `PROC_FILE` + `MARKER` (or dual-path files).
2. Add `pilot/handbuild/<id>/` sources implementing the intended fix as `klp_patch`.
3. Write or copy a run script: build → (optional mutate) → structural checks → QEMU predicates.
4. Confirm known-good: `INSMOD_RC=0`, `P2_PASS=1`, `P3_PASS=1` (if revert exercised).
5. If claiming a loader-invisible class: inject a loadable mutant; require structural and/or semantic fail while `INSMOD_RC=0`.
6. Record transcripts under `pilot/results/<id>/`.

## Docker stages

| Stage | Script | Produces |
| --- | --- | --- |
| **A — build modules from source** | `pilot/docker/run-build-modules.sh` | handbuild `.ko` against mounted/pinned kernel headers tree |
| **B — predicate replay** | `pilot/docker/run-all.sh` | QEMU transcripts (rebuilds handbuild cases as each script runs) |
| **Optional — kernel image** | `pilot/scripts/03-build-kernel.sh` | `pilot/build/bzImage` (long; not required if pin artifact present) |

See [`pilot/docker/README.md`](../pilot/docker/README.md).

## SoftwarX claim boundary

This release is a **documented case study on v6.6.47**, not a stratified production prevalence study. Sparse positive mutant detections show the instrument works; they are not industry rates.
