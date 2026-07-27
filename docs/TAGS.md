# Release tags

Annotated tags mark reproducible anchors. **`master` / `main` may advance** after a tag — always `git checkout <tag>` when reproducing a cited result.

| Tag | Commit | Purpose |
| --- | --- | --- |
| [`v0.1.0`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.0) | `b1c6bb7` | First SemVer release (LivepatchDiff / CITATION.cff) |
| [`softwarex-lp1-20260725c`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/softwarex-lp1-20260725c) | `386226e` | LivepatchDiff case-study pin (canonical dated freeze) |
| [`softwarex-lp1-20260725b`](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/softwarex-lp1-20260725b) | `86ba7a0` | Historical; superseded by `…c` |

## Quick checkout

```bash
git checkout v0.1.0
```

## Tag policy

- **SemVer / LivepatchDiff C1 / CITATION.cff** → `v0.1.0` (see [`CHANGELOG.md`](../CHANGELOG.md)).
- LivepatchDiff dated pin → `softwarex-lp1-20260725c`.
- Never cite floating `master` for published results.
- New SemVer tags when the release boundary changes — not on every doc commit.
