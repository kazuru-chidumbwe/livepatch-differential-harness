# Release tags

Annotated tags mark reproducible anchors. **`master` / `main` may advance** after a tag — always `git checkout <tag>` when reproducing a cited result.

| Tag | Commit | Purpose |
| --- | --- | --- |
| [`v0.2.1`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.2.1) | `6096119` | **cite pin** · second-pin depth · v6.1.119 (2 INCLUDE + C3) |
| [`v0.2.0`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.2.0) | `318eaa7` | **cite pin** · full pipeline · PRE + Dirty Pipe + 6 INCLUDE + v6.1.119 + PRE N=24 |
| [`v0.1.4`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.4) | `602fd39` | package cite pin · P3_PASS = contract · C6 P3_PASS=1 |
| [`v0.1.3`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.3) | `c421d01` | Prior cite pin · hardened P3 · predicate schema · C6 pack refresh |
| [`v0.1.2`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.2) | `9800eee` | package closeout (pre-hardening C6 P3 packs) |
| [`v0.1.1`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.1) | `01db96a` | C3 structural refresh · Zenodo capsule |
| [`v0.1.0`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.0) | `b97e6d9` | First SemVer release |
| [`pin-lp1-20260725c`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/pin-lp1-20260725c) | `416ef82` | dated freeze |

## Quick checkout

```bash
git checkout v0.2.1
```

## Tag policy

- **SemVer / CITATION.cff** → `v0.2.1` (see [`CHANGELOG.md`](../CHANGELOG.md)).
- Prior package pin → `v0.1.4`.
- Never cite floating `master` for published results.
- Zenodo C3: [`ZENODO.md`](ZENODO.md).
- Prefer `git rev-parse <tag>` over any short SHA copied from older docs.
