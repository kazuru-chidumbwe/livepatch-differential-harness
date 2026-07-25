# C3 data pack — structural ground truth

**Verification oracle:** `STRUCTURAL_BIND_PASS` from `pilot/scripts/verify-plt32-binding.py` (PLT32 sites that bound `seq_puts` in the good module bind `seq_putc` after redirect).

**Not an oracle:** coincidental `/proc/version` glyphs (e.g. ASCII `!` under `nokaslr`). Those are layout-dependent side-effects; semantic P2 checks the patch marker contract only.

Re-generate this pack by running `pilot/scripts/13-run-corpus-c3-survivable-sym.sh` (writes `structural-bind.txt`, refreshes this file).

## Expected structural outcome

```
STRUCTURAL_BIND_PASS=1
redirect=seq_puts->seq_putc
```

## Expected semantic P2

| Path | INSMOD_RC | P2_PASS |
| --- | ---: | ---: |
| good | 0 | 1 |
| perturb | 0 | 0 |
