# SUSE kgraft-patch pipeline check

**Date:** 2026-07-10  
**Question (LP outline §9):** Is SUSE `kgraft-patch` an independent build pipeline or a thin wrapper?

## Verdict

**Exclude `kgraft-patch` from pipelines under test.** It is a **packaging and registration wrapper** around hand-authored `klp_*` subpatches, not a source-patch→binary-diff builder comparable to `kpatch-build` or upstream `klp-build`.

## Evidence

| Source | Finding |
| --- | --- |
| [SUSE/kernel-livepatch](https://github.com/SUSE/kernel-livepatch) | `scripts/register-patches.sh`, `create-makefile.sh`, `tar-up.sh` — aggregate subpatch headers into `livepatch_main.c` / RPM spec; migrated from kGraft API to upstream `klp_patch` (commits `7e20201`, `f842fd5`). |
| `create-makefile.sh` | Generates Kbuild makefile for `kgraft-patch-@@RPMRELEASE@@.o` — standard out-of-tree module build against running kernel headers, **not** binary diff. |
| [SUSE/klp-build README](https://github.com/SUSE/klp-build) | Current SUSE production flow: `klp-ccp` extraction + IBS remote build; references `kgraft_patches` repo for **released** patches only (`format-patches` export). |
| dynup/kpatch + upstream Linux 6.19+ | `kpatch-build` deprecated in favor of in-tree `scripts/livepatch/klp-build` (`objtool klp`) — separate lineage from kernel-livepatch packaging scripts. |

## Pipeline table (locked for paper)

| Pipeline | Include in measurement study? |
| --- | --- |
| `kpatch-build` | **Yes** |
| Upstream `scripts/livepatch/klp-build` (6.19+) | **Yes** (when kernel pin permits) |
| SUSE `klp-build` + `klp-ccp` | Qualitative / optional vendor track |
| Legacy `kgraft-patch` packaging scripts | **No** — wrapper only |

## Time spent

~5 minutes (documentation + repo/README verification).
