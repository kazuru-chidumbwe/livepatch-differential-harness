# Release tags

Annotated tags mark reproducible anchors. **`master` / `main` may advance** after a tag — always `git checkout <tag>` when reproducing a cited result.

| Tag | Commit | Purpose |
| --- | --- | --- |
| [`v0.2.0`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.2.0) | `f7d612f` | **cite pin** · full-pipeline · PRE + Dirty Pipe + 6 INCLUDE + v6.1.119 + PRE N=24 |
| [`v0.1.4`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.4) | `a385a52` | package cite pin · P3_PASS = contract · C6 P3_PASS=1 |
| [`v0.1.3`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.3) | `029518e` | Prior cite pin · hardened P3 · predicate schema · C6 pack refresh |
| [`v0.1.2`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.2) | `3950fce` | package closeout (pre-hardening C6 P3 packs) |
| [`v0.1.1`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.1) | `aaa34e3` | C3 structural refresh · Zenodo capsule |
| [`v0.1.0`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.0) | `b1c6bb7` | First SemVer release |
| [`pin-lp1-20260725c`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/pin-lp1-20260725c) | `386226e` | dated freeze |

## Quick checkout

```bash
git checkout v0.2.0
```

## Tag policy

- **SemVer / cite-pin C1 / CITATION.cff** → `v0.2.0` (see [`CHANGELOG.md`](../CHANGELOG.md)).
- Prior package pin → `v0.1.4`.
- Never cite floating `master` for published results.
- Zenodo C3: [`ZENODO.md`](ZENODO.md).
