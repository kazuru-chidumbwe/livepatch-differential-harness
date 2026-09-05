# Structural relocation oracle (C3 / PLT32)

Cite-pin reference: `verify-plt32-binding.py` as shipped from `v0.1.4` onward (algorithm unchanged through `v0.2.2`).

## Purpose

Detect **silent callee misdirection** that the livepatch loader still accepts (`INSMOD_RC=0`). Runtime glyphs under `nokaslr` are **illustrative only**; structural bind is the C3 ground-truth oracle.

## Normalized tuple

Stage-A static plane records relocation sites as:

```
(section, r_offset, type, symbol, addend)
```

For the published C3 check, `verify-plt32-binding.py` consumes `readelf -rW` rows and retains the **binding projection**:

```
(r_offset, type=R_X86_64_PLT32, symbol)
```

Addends are **not** part of the PLT32 bind oracle (addend faults use `perturb-rodata-addend.py` / `R_X86_64_32S` and are checked by P2, not this script).

## Algorithm (`--check-redirect GOOD.ko PERT.ko SRC_SYM DST_SYM`)

1. Parse every `R_X86_64_PLT32` row from `readelf -rW` on `GOOD` and `PERT`.
2. Collect offsets in `GOOD` whose symbol name equals `SRC_SYM`.
3. Fail if no such sites exist.
4. For each offset `o`:
   - Require `GOOD` still binds `SRC_SYM` at `o`.
   - Require `PERT` binds `DST_SYM` at `o`.
5. Emit per-site `offset=… good=… pert=…` lines and `STRUCTURAL_BIND_PASS=1|0`.

Symbol strings are whatever `readelf` prints (local, weak, or global/extern names). The oracle does **not** re-resolve GOT/PLT trampolines; it compares the **relocation symbol field** at a fixed `r_offset` before vs after mutation.

## Mutation pairing

`perturb-plt32-redirect.py` rewrites the symbol index in `.rela.text` while preserving reloc type, so the module remains loadable. The verify script asserts the intended `SRC→DST` redirect at every former `SRC` site.

## False-positive / alias policy

| Risk | Policy in this package |
| --- | --- |
| Coincidental `/proc` glyphs (e.g. ASCII `!`) | **Rejected** as C3 GT; structural bind required |
| Identical-code folding / multiple PLT aliases | Oracle keys on **fixed `r_offset`**, not unique callee identity across the binary; ICF that moves sites would fail the offset loop (not observed on published pins) |
| Benign codegen (`-O2`/`-Os`, hand vs kpatch) | Structural oracle is **not** run as a bit-diff; benign packs use P2/P3 only |
| Addend-only churn | Out of scope for PLT32 bind; use 32S / P2 |

## Types normalized today vs deferred

| Type | Role today |
| --- | --- |
| `R_X86_64_PLT32` | C3 structural bind (`verify-plt32-binding.py`) |
| `R_X86_64_32S` | PILOT-02 addend swap (`perturb-rodata-addend.py`); P2 detects |
| `R_X86_64_GOTPCREL`, `R_X86_64_64`, LTO/CFI relaxations | **Not** checked; future work |
| ARM64 `R_AARCH64_*` | **Not** implemented (new guest pin + encodings) |

## Invoke

```bash
python3 pilot/scripts/verify-plt32-binding.py \
  --check-redirect GOOD.ko PERT.ko seq_puts seq_putc
```

Evidence exemplar: `pilot/results/LP-CORPUS-03-survivable-sym/structural-bind.txt`.
