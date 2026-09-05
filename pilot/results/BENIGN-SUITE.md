# Benign variation suite (aggregated)

| Control | Evidence path | Outcome |
| --- | --- | --- |
| PILOT-02 -O2/-Os hand | `pilot/results/LP-PILOT-02/benign-variation.txt` | `BENIGN_VARIATION_PASS=1` (Host B re-run 2026-09-05) |
| B1 hand vs kpatch | `pilot/results/LP-CORPUS-01-pipeline/predicate-transcript.txt` | P2/P3 agree |
| C6 -O2/-Os | `pilot/results/LP-CORPUS-06-kpatch-opt/` | P2/P3 contract pass |

Cross-compiler (Clang vs GCC) and multi-binutils matrices are not claimed.
KVM ablation: not runnable on Host B (`/dev/kvm` absent); published packs use TCG + `nokaslr`.
