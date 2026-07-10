# Livepatch Differential Harness

Differential test harness for Linux livepatch **build pipelines**. Identical source patches are built with multiple tools under a pinned kernel commit; outputs are compared for **trace-equivalence** using hand-built `klp_patch` reference modules, ELF normalization, and per-case predicate suites.

**Paper:** *Do Livepatch Builders Agree?* — outline [`pilot/PILOT-GATE-DELIVERABLES.md`](../../pilot/PILOT-GATE-DELIVERABLES.md)  
**Status:** scaffold Jul 2026 — **pilot gate not passed** (blocks corpus)

**Public release:** LP01 dev.to + S4 paper — **same window** (not blog-first). No public push until pilot + minimum corpus support paper claims.

---

## Quick start

Requirements (planned): Ubuntu 24.04 LTS guest, KVM, Python 3.11+, pinned GCC/binutils (see `docs/PROVENANCE.md`).

```bash
git clone https://github.com/<org>/livepatch-differential-harness.git
cd livepatch-differential-harness
bash scripts/bootstrap-env.sh    # toolchain pins + optional vendor checkouts
make smoke                       # structural normalizer self-test (no kernel yet)
make gate0                       # same-tool reproducibility gate (when VM ready)
make gate1                       # positive-control sensitivity gate
make reproduce                   # full pipeline (build → normalize → probe → matrix)
```

Expected output includes `results/matrix.csv` and `results/artifact-manifest.json` — the **canonical** published object for the blog/paper.

---

## Research question

> Can differential testing expose semantic inconsistencies among independently developed Linux livepatch build pipelines, when given identical source patches, compiler, and target kernel?

| Hypothesis | Statement |
| --- | --- |
| **H₀** | Pipelines produce observationally equivalent artifacts for identical fixes |
| **H₁** | At least one pipeline diverges in ELF livepatch structure, probe behavior, or operational signatures |

This is a **measurement study**, not a formal correctness proof.

---

## Three measurement channels

| Channel | What it compares | PASS / DIVERGE / INCONCLUSIVE |
| --- | --- | --- |
| **1 — Structural** | Normalized `.klp.rela.*` relocation tuples + livepatch ELF invariants | Tool vs tool under pinned toolchain |
| **2 — Functional** | Deterministic probe outputs after livepatch transition | vs Canonical prebuilt module (when available) |
| **3 — Operational** | Load/transition success, high-severity `dmesg` signatures | vs Canonical reference run |

**Canonical prebuilt module** is the **functional + operational reference**, not the structural oracle.

See [`docs/MEASUREMENT-PROTOCOL.md`](docs/MEASUREMENT-PROTOCOL.md) for pre-registered rules.

---

## Gating milestones (must pass before full corpus)

| Gate | Check |
| --- | --- |
| **Gate 0** | Same tool + same patch, two builds → identical normalized ELF; same module, two runs → identical probe/log outputs |
| **Gate 1** | Injected relocation-error positive control detected by Channel 1 and/or 2 (not normalized away) |

```bash
make gate0
make gate1
```

---

## Build pipelines under test

| Pipeline | Role |
| --- | --- |
| Canonical prebuilt | Functional + operational reference |
| `kpatch-build` | Historical / maintenance-mode pipeline |
| SUSE kgraft scripts | Independent pipeline (labeled) |
| `klp-build` | Upstream in-tree direction (objtool post-link) |
| Hand-rolled `klp_patch` | Optional; not a reference |

---

## Layout

```
patches/          Patch corpus + catalog.json
pipelines/        Per-tool build wrappers and flag extraction
normalize/        ELF + dmesg canonicalizers (Channel 1 / 3)
probes/           Per-patch deterministic runtime tests (Channel 2)
classifier/       Matrix aggregation (PASS / DIVERGE / INCONCLUSIVE)
scripts/          bootstrap-env.sh, gate0/1, reproduce
docs/             MEASUREMENT-PROTOCOL, ARCHITECTURE, PROVENANCE
blog/             dev.to draft
results/          matrix.csv, artifact-manifest.json (published)
logs/             Raw run output (gitignored)
artifacts/        Verified manifest copies from `make reproduce`
Makefile          smoke | gate0 | gate1 | reproduce | test
```

---

## Target environment (frozen for pilot)

- **Kernel:** Ubuntu 24.04 LTS, `6.8.0-40-generic`, identical `.config`
- **Compiler:** GCC 13.2.0, reported flags per tool
- **Testbed:** KVM snapshots between load/transition cycles

---

## License

MIT — see [LICENSE](LICENSE). Upstream tools (kpatch, kernel sources) retain their own licenses.

---

## Citation

If you use this harness in research, cite the repository URL and include the `run_id` / manifest SHA-256 from your `artifact-manifest.json`.
