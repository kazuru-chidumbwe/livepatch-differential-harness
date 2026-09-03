# Release tags

Annotated tags mark reproducible anchors. **master / main may advance** after a tag — always git checkout <tag> when reproducing a cited result.

| Tag | Commit | Purpose |
| --- | --- | --- |
| [v0.2.1](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.2.1) | 6016272 | cite pin · second-pin depth · v6.1.119 (2 INCLUDE + C3) |
| [v0.2.0](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.2.0) | cea4efa | cite pin · full pipeline · PRE + Dirty Pipe + 6 INCLUDE + v6.1.119 + PRE N=24 |
| [v0.1.4](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.4) | 2d63fb7 | package cite pin · P3_PASS = contract · C6 P3_PASS=1 |
| [v0.1.3](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.3) | 93c3367 | Prior cite pin · hardened P3 · predicate schema · C6 pack refresh |
| [v0.1.2](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.2) | cdbf6e8 | package closeout (pre-hardening C6 P3 packs) |
| [v0.1.1](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.1) | c638bca | C3 structural refresh · Zenodo capsule |
| [v0.1.0](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/releases/tag/v0.1.0) | 7079019 | First SemVer release |
| [pin-lp1-20260725c](https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/pin-lp1-20260725c) | 7ab81db | dated freeze |

## Quick checkout

`ash
git checkout v0.2.1
`

## Tag policy

- **SemVer / CITATION.cff** → 0.2.1 (see [CHANGELOG.md](../CHANGELOG.md)).
- Prior package pin → 0.1.4.
- Never cite floating master for published results.
- Zenodo C3: [ZENODO.md](ZENODO.md).
- Prefer git rev-parse <tag> over any short SHA copied from older docs.
