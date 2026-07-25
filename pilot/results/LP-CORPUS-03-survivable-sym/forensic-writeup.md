# LP-CORPUS-03 forensic — silent survivable PLT32 redirect

**Date:** 2026-07-10 (structural oracle update 2026-07-25)  
**Perturbation:** one-way PLT32 redirect `seq_puts` → `seq_putc`

---

## Ground-truth verification (required)

C3 is verified by **structural PLT32 binding**, not by any particular wrong character in `/proc/version`.

| Check | Tool | Pass criterion |
| --- | --- | --- |
| **STRUCTURAL_BIND_PASS** | `pilot/scripts/verify-plt32-binding.py --check-redirect` | Every PLT32 site that bound `seq_puts` in the good module binds `seq_putc` after redirect |
| **INSMOD_RC** | QEMU | `0` on both good and perturbed (loader-blind-spot claim) |
| **Semantic P2** | QEMU `grep MARKER` | Good: `P2_PASS=1`; Perturb: `P2_PASS=0` (patch marker contract) |

Ship evidence: `structural-bind.txt`, `C3-DATA-PACK.md`, `predicate-transcript.txt`.

**Not an oracle:** ASCII `!` (or any other single-byte glyph) under `nokaslr`. That output is a **layout coincidence** of rodata placement for this pin. A different string, link layout, or ASLR-enabled boot can produce a different (possibly unprintable) byte. The threat class is **silent wrong-callee binding after successful load**.

---

## What happened (illustrative runtime)

| Path | INSMOD | dmesg | Semantic P2 (marker) | Structural bind |
| --- | --- | --- | --- | --- |
| Good | 0 | clean transition | 1 | `seq_puts` at redirected site(s) |
| Perturb | 0 | **no fault, no oops** | 0 | `seq_putc` at those site(s) |

Load-time livepatch checks pass. Runtime is **semantically wrong but stable** — structural triage proves the mis-bind; predicate proves the patch contract failed.

On this pin, a common observable side-effect is a truncated/wrong `/proc/version` line (historically recorded as leading space + `!`). Treat that glyph as illustrative only.

---

## Calling convention at the faulted callsite

**Good path:** `seq_puts(m, msg)` — System V AMD64

| Reg | Role |
| --- | --- |
| `rdi` | `struct seq_file *m` |
| `rsi` | `const char *msg` — pointer to marker string in `.rodata` |

**Perturbed path:** PLT32 still resolves to a **valid kernel symbol** (`seq_putc`), but the callsite layout is wrong:

| Reg | Value at call | `seq_putc` expects |
| --- | --- | --- |
| `rdi` | `m` | `struct seq_file *` ✓ |
| `rsi` | **pointer** to string in `.rodata` | **`int c`** (truncated to low byte) |

`seq_putc` writes **one character**: `(unsigned char)rsi`. Which character appears depends on the low byte of the pointer — **not** a stable property of the bug class.

Representative disassembly (good module):

```
  mov    rdi, rbx          # m
  lea    rsi, [rip+msg]    # pointer to full string  (perturb: still passed to seq_putc)
  call   seq_puts          # perturb: call seq_putc instead
```

---

## Why the kernel does not intervene

1. **PLT32 resolves to a legal vmlinux symbol** (`seq_putc`) — non-null, executable, in kernel text.
2. **No type information at load time** — relocations bind symbol indices, not C prototypes.
3. **Consistency model checks function *replacement* addresses**, not callee correctness inside the replacement function's PLT/GOT slots.

---

## C2 vs C3 — ABI mismatch outcomes

| Case | Swap | Callee at `seq_puts` site | `rsi` at call | Runtime |
| --- | --- | --- | --- | --- |
| **C2** (reciprocal) | `seq_printf` ↔ `seq_putc` | `seq_printf` at putc site | `0x21` as **format pointer** | **#PF** (dereference) |
| **C3** (one-way) | `seq_puts` → `seq_putc` | `seq_putc` at puts site | string **pointer** | **Silent** semantic fail (glyph contingent) |

**Lesson:** code-relocation errors can be **crashy or stealthy** depending on whether the wrong callee **dereferences** the register-as-pointer.

---

## Mechanism #1 triptych (evaluation table)

| Case | Reloc type | Runtime | Structural / P2 | Kernel silent? |
| --- | --- | --- | --- | --- |
| PILOT-02 | data `R_X86_64_32S` addend | wrong string | P2=0 | Yes |
| C2 | code PLT32 reciprocal | #PF on invoke | P2=0 | No (crash) |
| C3 | code PLT32 one-way | wrong output (glyph contingent) | **STRUCTURAL_BIND_PASS=1** + P2=0 | Yes |

---

## Claim boundary

Demonstrates **silent function misdirection** under loadable module + successful transition, verified by **relocation symbol binding**. Does not claim all wrong-function swaps are silent (C2 counterexample). Does not claim any particular corrupted byte is universal. Predicate harness + structural triage are the practical detection layers.
