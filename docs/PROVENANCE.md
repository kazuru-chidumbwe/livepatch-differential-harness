# Experiment provenance and canonical artifacts

## Canonical object

**`results/artifact-manifest.json`** is the primary published object. Each cell entry includes:

- `patch_id`, `tool_id`
- `channel_1`, `channel_2`, `channel_3`, `cell_outcome`
- `n_elf_sha256` — hash of normalized structural representation
- `probe_output_sha256`, `ops_signature_sha256`
- `artifact_refs` — paths into `logs/`
- `provenance` — harness commit, kernel version, compiler flags, objtool version

Derived files (`matrix.csv`, blog tables) are views — cite the manifest.

## Reproducing from a clean checkout

```bash
git checkout <tag from manifest>
bash scripts/bootstrap-env.sh
make gate0
make gate1
make reproduce
make verify-manifest RESULTS_DIR=results/<run-id>
```

Verified manifests are copied to `artifacts/<run-id>-artifact-manifest.json` by `scripts/reproduce.sh`.

## Target environment (pilot freeze)

| Field | Value |
| --- | --- |
| Host OS | Ubuntu 24.04 LTS |
| Kernel | `6.8.0-40-generic` |
| Compiler | GCC 13.2.0 |
| Binutils | 2.42 (pinned) |
| Testbed | KVM qcow2 snapshot |

## Per-run provenance (`provenance_version`: 1)

Each run record embeds:

- `harness_commit`
- `patch_sha256`
- `tool_id`, `compiler_flags_reported`
- `kernel_release`, `config_sha256`
- `objtool_version`
- `run_index` (for latency replicates)

## Public reproduction pin

| Field | Value |
| --- | --- |
| SoftwarX tag | `softwarex-lp1-20260725b` |
| Gate | `pilot/docker/run-all.sh` (illustrative corpus) |
| Blog | Linked from SoftwarX / programme posts after accept — **not** drafted in this repo |

## MADHAT_SANITY

`results/MADHAT_SANITY.txt` — `sha256sum` of every tool output binary and normalized representation for cross-machine verification (Gate 0 artifact).
