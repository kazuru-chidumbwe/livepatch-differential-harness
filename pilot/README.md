# Livepatch pilot (LP-PILOT-01)

Proves whether hand-built `klp_patch` ground truth is tractable before corpus work.

**Status:** see [`PILOT-STATUS.md`](PILOT-STATUS.md)

## Pins

- Kernel: `v6.6.47` (`linux.git` stable)
- Compiler: GCC 13
- Case: `cmdline_proc_show` — same target as `samples/livepatch/livepatch-sample.c`

## Scripts (run on Linux lab or WSL with sudo)

| Script | Purpose |
| --- | --- |
| `scripts/00-install-host-deps.sh` | apt packages |
| `scripts/01-fetch-kernel.sh` | clone to `$WORK_ROOT/linux` |
| `scripts/01-fetch-kernel-local.sh` | clone to repo `pilot/build/linux` (no sudo) |
| `scripts/02-config-kernel.sh` | defconfig + livepatch fragment |
| `scripts/03-build-kernel.sh` | build bzImage + vmlinux |

## Lab host

Use a Linux lab host with Docker/QEMU when available. Set `WORK_ROOT` to a writable kernel build tree (default `$HOME/livepatch-pilot`).
## Gate deliverables (checklist)

- [x] `pilot/results/kernel.commit` + `kernel.config` + `kernel.sha256`
- [x] Hand-built module under `pilot/handbuild/LP-PILOT-01/`
- [x] Relocation table + derivation notes
- [x] Failure log + iteration count to first `insmod` (**1**)
- [x] Revert-and-retest pass
- [x] Perturbation-sanity pass
- [x] Predicate table + coverage bounds
- [x] Time accounting hours

**Master record:** [`PILOT-GATE-DELIVERABLES.md`](PILOT-GATE-DELIVERABLES.md)

## Decision

If steps 3–5 complete without fatal surprise → proceed with corpus cases under `pilot/cases/` and `pilot/results/`.

If hand-build time is prohibitive → narrow case or reconsider methodology **before** corpus optimism.
