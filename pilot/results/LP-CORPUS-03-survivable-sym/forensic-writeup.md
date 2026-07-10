# LP-CORPUS-03 forensic — silent survivable PLT32 redirect

**Date:** 2026-07-10  
**Perturbation:** one-way PLT32 redirect `seq_puts` → `seq_putc` at `r_offset 0x2d`

---

## What happened

| Path | INSMOD | dmesg | `/proc/version` | P2 |
| --- | --- | --- | --- | --- |
| Good | 0 | clean transition | full marker + `!` | 1 |
| Perturb | 0 | **no fault, no oops** | ` !` (leading space + `!`) | 0 |

Load-time livepatch checks pass. Runtime is **semantically wrong but stable** — predicate catches it.

---

## Calling convention at the faulted callsite

**Good path** (`+0x2d`): `seq_puts(m, msg)` — System V AMD64

| Reg | Role |
| --- | --- |
| `rdi` | `struct seq_file *m` |
| `rsi` | `const char *msg` — pointer to `"LP-PILOT-02 patched-by-harness!\n"` in `.rodata` |

**Perturbed path:** PLT32 still resolves to a **valid kernel symbol** (`seq_putc`), but the callsite layout is wrong:

| Reg | Value at call | `seq_putc` expects |
| --- | --- | --- |
| `rdi` | `m` | `struct seq_file *` ✓ |
| `rsi` | **pointer** to string in `.rodata` | **`int c`** (truncated to low byte) |

`seq_putc` writes **one character**: `(unsigned char)rsi`. On x86_64 the pointer to `msg[]` has low byte **`0x21` = ASCII `'!'`** (address ends in `…21` for this link). The rest of the string is never read. **No invalid dereference** — only wrong semantics.

Representative disassembly (good module):

```
  mov    rdi, rbx          # m
  lea    rsi, [rip+msg]    # pointer to full string  (perturb: still passed to seq_putc)
  call   seq_puts          # perturb: call seq_putc instead
```

Second call at `+0x3a` (`seq_putc(m, '!')`) still runs — hence output ` !` (space from partial buffer state + `!` from misdirected first call).

---

## Why the kernel does not intervene

1. **PLT32 resolves to a legal vmlinux symbol** (`seq_putc`) — non-null, executable, in kernel text.
2. **No type information at load time** — relocations bind symbol indices, not C prototypes.
3. **Consistency model checks function *replacement* addresses**, not callee correctness inside the replacement function's PLT/GOT slots.

---

## C2 vs C3 — ABI mismatch outcomes

| Case | Swap | Callee at `seq_puts` site | `rsi` at call | Runtime |
| --- | --- | --- | --- | --- |
| **C2** (reciprocal) | `seq_printf` ↔ `seq_putc` | `seq_printf` at putc site | `0x21` as **format pointer** | **#PF** (dereference `0x21`) |
| **C3** (one-way) | `seq_puts` → `seq_putc` | `seq_putc` at puts site | string **pointer** | **Silent** — low byte `0x21` → `'!'` |

**Lesson:** code-relocation errors can be **crashy or stealthy** depending on whether the wrong callee **dereferences** the register-as-pointer.

---

## Mechanism #1 triptych (evaluation table)

| Case | Reloc type | Runtime | P2 | Kernel silent? |
| --- | --- | --- | --- | --- |
| PILOT-02 | data `R_X86_64_32S` addend | wrong string | 0 | Yes |
| C2 | code PLT32 reciprocal | #PF on invoke | 0 | No (crash) |
| C3 | code PLT32 one-way | wrong output ` !` | 0 | Yes |

---

## Claim boundary

Demonstrates **silent function misdirection** under loadable module + successful transition. Does not claim all wrong-function swaps are silent (C2 counterexample). Predicate harness is the practical detection layer.
