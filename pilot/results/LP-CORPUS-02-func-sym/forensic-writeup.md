# LP-CORPUS-02 forensic — PLT32 swap crash analysis

**Date:** 2026-07-10  
**Perturbation:** reciprocal swap `seq_printf` ↔ `seq_putc` PLT32 indices

## Load-time (silent)

```
livepatch: enabling patch 'livepatch_version'
livepatch: 'livepatch_version': patching complete
INSMOD_RC=0
```

No `klp_resolve` error. PLT32 callee identity not validated against callsite semantics.

## Fault site

```
#PF: error_code(0x0000) - not-present page
 hb_version_proc_show+0x3c/0x50 [livepatch_version]
```

**Disassembly (good module):**

| Offset | Instruction | Intended call |
| --- | --- | --- |
| `+0x2f` | `call` | `seq_printf(m, fmt, ...)` |
| `+0x3c` | `call` | `seq_putc(m, '!')` — `esi=0x21` |

After reciprocal swap, **`+0x3c` invokes `seq_printf`** with `rsi=0x21` (ASCII `!`) interpreted as a **format-string pointer** → dereference of non-canonical/unmapped address → **#PF**.

## Why KASAN stays silent

This is not an out-of-bounds access within a mapped object. The CPU faults on a **bogus pointer** derived from an integer argument (`0x21`) passed to a variadic callee at the wrong callsite. KASAN instruments valid memory regions; it does not catch "call seq_printf with a char value as pointer."

## Failure mode classification

| Class | PILOT-02 (data reloc) | C2 (code reloc, seq_printf↔seq_putc) |
| --- | --- | --- |
| `insmod` | OK | OK |
| Runtime | **Silent** wrong string | **Loud** #PF |
| P2 | FAIL (wrong marker) | FAIL (no complete output) |

**Companion finding:** mechanism #1 code-relocation can pass load and **crash on invoke** when arity/ABI mismatch. Survivable silent code-relocation is **not yet shown** — see LP-CORPUS-03 (`seq_puts` → `seq_putc` one-way redirect).
