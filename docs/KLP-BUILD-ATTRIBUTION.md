# Upstream klp-build attribution

This note is for readers who only see the repository root and need the grey-literature pointer that the paper cites for timeliness of the *producer* pipeline.

## What this harness claims

- Tool ID `klp-build-upstream` means in-tree `scripts/livepatch/klp-build` on a Linux 6.19+ tree.
- Lab evidence on cite pin `v0.2.0` / later: tool *present* on a cloned v6.19 tree (`pilot/results/LP-KLP-BUILD-UPSTREAM/`). Equivalence rates versus hand / `kpatch-build` are deferred.
- Published cross-toolchain packs compare hand vs `kpatch-build` only.

## Author attribution (do not write “et al.”)

| Field | Value |
| --- | --- |
| Author | Josh Poimboeuf (sole series author for the objtool / klp-build work cited here) |
| Not co-authors | Acked-by / Tested-by contributors (for example Petr Mladek, Joe Lawrence) |
| Role in this paper | Timeliness of the upstream *build* path beside LivepatchDiff; not peer-reviewed SOTA for post-build revert eligibility |

## Primary sources (grey literature)

1. J. Poimboeuf, “objtool, livepatch: Livepatch module generation” (RFC / series), LKML / LWN, 2 Sep. 2024. https://lwn.net/Articles/988575/
2. J. Poimboeuf, “objtool,livepatch: klp-build livepatch module generation” (series coverage), LWN / LKML, 2025. https://lwn.net/Articles/1020723/
3. J. Poimboeuf, “[GIT PULL] objtool changes for v6.19” (klp-build livepatch module generation), LKML, 1 Dec. 2025. https://lists.openwall.net/linux-kernel/2025/12/01/508
4. In-tree script (retrieve current tip): https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/scripts/livepatch/klp-build

## Lab clone pin used for presence probe

`pilot/results/LP-KLP-BUILD-UPSTREAM/klp-build-probe.log` records checkout of Linux commit `05f7e89ab9731565d8a62e3b5d1ec206485eeb0b` with `scripts/livepatch/klp-build` present. That is a presence pin for tooling availability, not a claim that every klp-build series commit SHA is reproduced in this repository.

## Related software cite (this package)

`CITATION.cff` is for citing *LivepatchDiff* (Kazuru). It is not the Poimboeuf bibliography entry.
