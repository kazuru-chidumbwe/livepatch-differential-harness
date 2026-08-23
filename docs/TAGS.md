# Release tags

Annotated tags mark reproducible anchors. **`master` / `main` may advance** after a tag — always `git checkout <tag>` when reproducing a cited result.

| Tag | Commit | Purpose |
| --- | --- | --- |
| [`v0.1.3`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.3) | `8668d99` (retag may advance tip) | package cite pin · hardened P3 · predicate schema · C6 pack refresh |
| [`v0.1.2`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.2) | `3950fce` | package closeout (pre-hardening C6 P3 packs) |
| [`v0.1.1`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.1) | `aaa34e3` (tag also includes `b7adce7` TAGS pin) | C3 structural refresh · Zenodo capsule |
| [`v0.1.0`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.0) | `b1c6bb7` | First SemVer release (package / CITATION.cff) |
| [`softwarex-lp1-20260725c`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/softwarex-lp1-20260725c) | `386226e` | package case-study pin (canonical dated freeze) |
| [`softwarex-lp1-20260725b`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/softwarex-lp1-20260725b) | `86ba7a0` | Historical; superseded by `…c` |

## Quick checkout

```bash
git checkout v0.1.3
```

## Tag policy

- **SemVer / package C1 / CITATION.cff** → `v0.1.3` (see [`CHANGELOG.md`](../CHANGELOG.md)).
- Historical package dated pin → `softwarex-lp1-20260725c`.
- Never cite floating `master` for published results.
- New SemVer tags when the release boundary changes — not on every doc commit.
- Zenodo C3: [`ZENODO.md`](ZENODO.md).
