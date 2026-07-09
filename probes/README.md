# Runtime probes (Channel 2)

One deterministic probe per patch in the corpus.

## Requirements

- trigger the patched code path without races or random delays
- collect bitwise-comparable outputs (syscall result, `/proc` state, kprobe trace)
- verify livepatch transition completed before assertions
- report gcov branch coverage for patched function(s); <95% → INCONCLUSIVE

## Layout (planned)

```
probes/
  LP-PATCH-01/
    run.sh          # guest-side entrypoint
    assert.py       # expected outputs vs reference
    coverage.gcov   # emitted post-run
```

Probes run inside the KVM guest after module load and transition.
