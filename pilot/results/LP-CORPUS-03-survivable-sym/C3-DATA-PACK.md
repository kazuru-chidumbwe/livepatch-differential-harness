# LP-CORPUS-03 (C3) — verification data pack

**Date:** 2026-07-10 (re-verified on lab)  
**Gate status:** **PASSED** — C2-level scrutiny (reloc, disasm, serial/dmesg, predicate)  
**Perturbation:** one-way PLT32 redirect `seq_puts` → `seq_putc` at `r_offset 0x29`

---

## Predicate transcript (QEMU)

### Good module

```
INSMOD_RC=0
---PROC---
LP-PILOT-02 patched-by-harness!
P2_PASS=1
```

### Perturbed module

```
INSMOD_RC=0
---PROC---
 !          (leading space + '!'; P2_FAIL)
P2_PASS=0
```

**dmesg (both paths):** clean livepatch transition; no oops, no #PF.

Full serial: `good-serial.log`, `perturb-serial.log`

---

## Relocation diff

```
Good:
  0x29  R_X86_64_PLT32  seq_puts - 4
  0x36  R_X86_64_PLT32  seq_putc - 4

Perturbed:
  0x29  R_X86_64_PLT32  seq_putc - 4   # was seq_puts
  0x36  R_X86_64_PLT32  seq_putc - 4
```

See `relocation-diff.txt`.

---

## Disassembly (`hb_version_proc_show`)

| Offset | Good (intended) | Perturbed |
| --- | --- | --- |
| `+0x28` | `call seq_puts` — `rsi` = rodata string ptr | `call seq_putc` — `rsi` still string ptr |
| `+0x35` | `call seq_putc` — `esi=0x21` (`'!'`) | same |

At `+0x28`, `seq_putc` consumes **low byte of `rsi`** (pointer passed where `int c` expected). Under this pin (`nokaslr`), the string lives at a rodata address whose low byte is **`0x21` = `'!'`** — a **layout coincidence**, not a universal output for every `seq_puts`→`seq_putc` swap.

See `disasm-good.txt`, `disasm-perturb.txt`.

---

## Layout dependence (intro caveat source)

- **Observed:** `/proc/version` shows ` !` on perturb path.  
- **Mechanism:** pointer low byte → character written by `seq_putc`.  
- **Not claimed:** every mis-binding prints `'!'`. Different strings, link order, or ASLR would yield different (possibly unprintable) bytes.  
- **Environment:** v6.6.47 pin, `nokaslr`, gcc-13, QEMU serial test.

---

## Forensic writeup (evaluation — ship verbatim)

`forensic-writeup.md` — do not edit for paper §5.1.1.
