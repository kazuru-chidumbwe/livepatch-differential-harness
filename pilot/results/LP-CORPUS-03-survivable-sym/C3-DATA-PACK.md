# C3 data pack — structural ground truth

**Verification oracle:** `STRUCTURAL_BIND_PASS` from `pilot/scripts/verify-plt32-binding.py` (PLT32 sites that bound `seq_puts` in the good module bind `seq_putc` after redirect).

**Not an oracle:** coincidental `/proc/version` glyphs (e.g. ASCII `!` under `nokaslr`). Those are layout-dependent side-effects; P2 checks the patch marker contract only.

## Structural bind

```
# structural PLT32 redirect check
good=/opt/atlas/repos/livepatch-differential-harness/pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.ko
pert=/opt/atlas/repos/livepatch-differential-harness/pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.seqputs-to-putc.ko
redirect=seq_puts->seq_putc
sites=0x29
offset=0x29 good=seq_puts pert=seq_putc
STRUCTURAL_BIND_PASS=1
note: runtime observables (including coincidental glyphs) are illustrative only; this check is the C3 ground-truth oracle.
```

## Relocation triage

```
# LP-CORPUS-03 survivable function redirect
Redirect: seq_puts PLT32 -> seq_putc (one-way; same register arity at call site)

## Good PLT32
0000000000000029  0000004000000004 R_X86_64_PLT32         0000000000000000 seq_puts - 4
0000000000000036  0000003c00000004 R_X86_64_PLT32         0000000000000000 seq_putc - 4
## Perturbed PLT32
0000000000000029  0000003c00000004 R_X86_64_PLT32         0000000000000000 seq_putc - 4
0000000000000036  0000003c00000004 R_X86_64_PLT32         0000000000000000 seq_putc - 4

## Structural binding oracle (C3 ground truth)
# structural PLT32 redirect check
good=/opt/atlas/repos/livepatch-differential-harness/pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.ko
pert=/opt/atlas/repos/livepatch-differential-harness/pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.seqputs-to-putc.ko
redirect=seq_puts->seq_putc
sites=0x29
offset=0x29 good=seq_puts pert=seq_putc
STRUCTURAL_BIND_PASS=1
note: runtime observables (including coincidental glyphs) are illustrative only; this check is the C3 ground-truth oracle.
```

## Predicate transcript (semantic P2)

```
=== STRUCTURAL (required for C3 claim) ===
# structural PLT32 redirect check
good=/opt/atlas/repos/livepatch-differential-harness/pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.ko
pert=/opt/atlas/repos/livepatch-differential-harness/pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.seqputs-to-putc.ko
redirect=seq_puts->seq_putc
sites=0x29
offset=0x29 good=seq_puts pert=seq_putc
STRUCTURAL_BIND_PASS=1
note: runtime observables (including coincidental glyphs) are illustrative only; this check is the C3 ground-truth oracle.

=== GOOD (semantic P2 must PASS) ===
QEMU 10.0.11 monitor - type 'help' for more information
(qemu) === CORPUS_C3_good ===
[   47.284937] livepatch_corpus03: loading out-of-tree module taints kernel.
[   47.287100] livepatch_corpus03: tainting kernel with TAINT_LIVEPATCH
[   47.409610] livepatch: enabling patch 'livepatch_corpus03'
[   47.792371] livepatch: 'livepatch_corpus03': starting patching transition
[   52.627332] livepatch: 'livepatch_corpus03': patching complete
KLP_FORCE=1
INSMOD_RC=0
---DMESG---
[   47.284937] livepatch_corpus03: loading out-of-tree module taints kernel.
[   47.287100] livepatch_corpus03: tainting kernel with TAINT_LIVEPATCH
[   47.409610] livepatch: enabling patch 'livepatch_corpus03'
[   47.792371] livepatch: 'livepatch_corpus03': starting patching transition
[   52.627332] livepatch: 'livepatch_corpus03': patching complete
---PROC---
!P2_PASS=1

=== PERTURB_SEQPUTS_TO_PUTc (INSMOD=0 + semantic P2 must FAIL) ===
QEMU 10.0.11 monitor - type 'help' for more information
(qemu) === CORPUS_C3_perturb ===
[   49.144726] livepatch_corpus03: loading out-of-tree module taints kernel.
[   49.146898] livepatch_corpus03: tainting kernel with TAINT_LIVEPATCH
[   49.318681] livepatch: enabling patch 'livepatch_corpus03'
[   49.666654] livepatch: 'livepatch_corpus03': starting patching transition
[   54.706797] livepatch: 'livepatch_corpus03': patching complete
KLP_FORCE=1
INSMOD_RC=0
---DMESG---
[   49.144726] livepatch_corpus03: loading out-of-tree module taints kernel.
[   49.146898] livepatch_corpus03: tainting kernel with TAINT_LIVEPATCH
[   49.318681] livepatch: enabling patch 'livepatch_corpus03'
[   49.666654] livepatch: 'livepatch_corpus03': starting patching transition
[   54.706797] livepatch: 'livepatch_corpus03': patching complete
---PROC---
 !P2_PASS=0
```
