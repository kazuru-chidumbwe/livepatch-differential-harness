# Build pipeline wrappers

Thin wrappers around each livepatch build tool. Responsibilities:

1. Invoke build with **pinned** toolchain (or record required overrides)
2. Emit `build-provenance.json` (flags, objtool version, commit ids)
3. Copy output `.ko` to `build/<patch-id>/<tool-id>/livepatch.ko`

## Pipelines

| Directory | Tool |
| --- | --- |
| `canonical/` | Reference module ingestion (no build; copy prebuilt) |
| `kpatch-build/` | dynup/kpatch |
| `kgraft/` | SUSE kgraft scripts |
| `klp-build/` | `scripts/livepatch/klp-build` (in-tree) |

Each wrapper must support `make -j1` (or equivalent serialization) for determinism experiments.

## Flag extraction

Report compiler and linker flags actually used. Overrides vs the pinned baseline are classified as **environment divergence**, not tool-intrinsic bugs.
