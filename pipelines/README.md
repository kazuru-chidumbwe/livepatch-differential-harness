# Build pipeline wrappers

Thin wrappers around each livepatch build tool. Responsibilities:

1. Invoke build with **pinned** toolchain (or record required overrides)
2. Emit `build-provenance.json` (flags, objtool version, commit ids)
3. Copy output `.ko` to `build/<patch-id>/<tool-id>/livepatch.ko`

## Pipelines (qualified IDs)

| Directory | Qualified ID | Tool |
| --- | --- | --- |
| `kpatch-build/` | `kpatch-build` | dynup/kpatch |
| `klp-build-upstream/` | `klp-build-upstream` | `scripts/livepatch/klp-build` (kernel 6.19+) |
| `suse-klp-build/` | `SUSE-klp-build` | SUSE/klp-build + klp-ccp (optional vendor track) |
| `kernel-livepatch-packaging/` | — | SUSE kernel-livepatch RPM scripts — **not a builder** |

**Naming rule:** In prose, write `klp-build-upstream` vs `SUSE-klp-build`. Bare `klp-build` is ambiguous and must not appear in paper tables.

Hand-built reference modules live under `pilot/handbuild/` — not under `pipelines/`.

## Flag extraction

Report compiler and linker flags actually used. Overrides vs the pinned baseline are classified as **environment divergence**, not tool-intrinsic bugs.
