# Harness architecture

```
Patch corpus (catalog.json)
    ↓
Build (pipelines/* — pinned toolchain per tool)
    ↓
Normalize (Channel 1 ELF + Channel 3 dmesg)
    ↓
Runtime (KVM guest — load, transition, probes)
    ↓
Classify (matrix.py → PASS / DIVERGE / INCONCLUSIVE)
    ↓
Artifact (artifact-manifest.json — canonical)
```

## Canonical artifact

**`results/artifact-manifest.json`** is the primary published object. Each matrix cell bundles:

- patch id, tool id, channel outcomes
- normalized structural hash (`N(ELF)`)
- probe output hashes
- operational signature hash
- raw log paths under `logs/`

Derived `matrix.csv` and blog tables are views — cite the manifest.

## Reference model

| Comparison | Against what |
| --- | --- |
| Channel 1 (structural) | Primarily **tool vs tool** under pinned toolchain + ELF invariant checks |
| Channel 2 (functional) | **Canonical prebuilt** module behavior |
| Channel 3 (operational) | **Canonical** load/transition/log signature |

Canonical is **not** the structural oracle (it may be built with different flags/toolchain).

## Pipeline layers

| Layer | Directory | Responsibility |
| --- | --- | --- |
| Corpus | `patches/` | Patch metadata, applicability constraints |
| Build | `pipelines/` | Wrapper scripts, flag extraction, provenance |
| Normalize | `normalize/` | ELF tuple extraction, dmesg canonicalization |
| Probe | `probes/` | Per-patch deterministic tests + coverage |
| Classify | `classifier/` | Aggregation, manifest emission |
| Reproduce | `scripts/` | Gate 0/1, end-to-end `reproduce.sh` |

## Commands

| Command | Purpose |
| --- | --- |
| `make smoke` | Normalizer self-test (no kernel) |
| `make gate0` | Build + harness reproducibility |
| `make gate1` | Positive-control sensitivity |
| `make reproduce` | Full pilot pipeline |
| `make verify-manifest` | Check manifest completeness |

## Methodology (frozen wording)

This pilot uses an **exploratory** patch corpus (8–15 patches). The primary contribution is the differential-testing framework and normalization pipeline, not exhaustive kernel coverage. Null structural/functional equivalence across the corpus is still valuable when Gate 1 demonstrates harness sensitivity.
