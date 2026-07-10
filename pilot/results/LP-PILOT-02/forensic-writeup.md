# LP-PILOT-02 forensic writeup — loadable data-relocation perturbation

**Date:** 2026-07-10  
**Kernel:** v6.6.47 @ `4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7`  
**Case:** `version_proc_show` → `/proc/version`

---

## What the bug actually is (not memory corruption)

The loadable perturbation is a **wrong pointer** into intact `.rodata`, not corrupted or overwritten kernel memory.

| Aspect | Good module | Perturbed module |
| --- | --- | --- |
| Mechanism | `.rela.text` `R_X86_64_32S` addends point at correct string literals | Addends `0` ↔ `0x18` **swapped** in `.rela.text` |
| Load-time | `INSMOD_RC=0` | `INSMOD_RC=0` (kernel accepts relocation) |
| Runtime | `seq_printf` emits marker + suffix | `seq_printf` emits **wrong** literal pair (valid bytes, wrong selection) |
| Memory integrity | N/A | **Unchanged** — no smash, no OOB write |

**We do not claim** memory corruption. A `/proc/kcore` snapshot hunt would be evidence for a mechanism we did not test. Evidence below: relocation diff, silent dmesg, predicate transcript.

---

## Relocation diff (structural)

From `relocation-table.txt` — `.rela.text` entries for `hb_version_proc_show`:

```
# Good path (excerpt)
000000000028  ... R_X86_64_32S  .rodata + 0      # marker[]
00000000002f  ... R_X86_64_32S  .rodata + 0x18   # suffix[]
00000000003b  ... R_X86_64_PLT32 seq_printf
000000000048  ... R_X86_64_PLT32 seq_putc
```

**Perturbation:** `perturb-rodata-addend.py` swaps the two `R_X86_64_32S` addends in the on-disk `.rela.text` section. PLT32 targets (`seq_printf`, `seq_putc`) unchanged — codegen and external calls identical; only **which rodata symbols are referenced** changes.

Full objdump/disassembly diff: `disassembly-diff.txt` (generated on lab by `11-forensic-artifacts.sh`).

---

## dmesg silence (behavioral evidence)

QEMU serial capture shows **no livepatch error**, **no Oops**, **no relocation complaint** on the perturbation path:

```
=== PERTURB_LOADABLE ===
INSMOD_RC=0
P2_PASS=0
```

Good path for contrast (`validation-summary.txt`):

```
=== PRE_PATCH ===
INSMOD_RC=0
=== POST_PATCH ===
P2_PASS=1
=== POST_REVERT ===
P3_PASS=1
=== DONE ===
```

Silent load + wrong `/proc/version` content = **semantic divergence invisible to `insmod`**, visible to user-space predicate.

---

## Predicate pseudocode (P2 / P3)

These are the exact checks from `08-run-lp-pilot-02.sh` init scripts — userspace `/proc` oracle, not BPF.

### P2 — post-patch marker present

```
PROC_FILE = /proc/version
MARKER    = "LP-PILOT-02 patched-by-harness"

read PROC_FILE into stdout
if stdout contains MARKER:
    emit P2_PASS=1
else:
    emit P2_PASS=0
```

**Good path:** `P2_PASS=1`  
**Perturbed (loadable):** `P2_PASS=0` with `INSMOD_RC=0`

### P3 — revert restores pre-patch output

```
capture PRE  = read(PROC_FILE) before insmod
insmod livepatch-version.ko
capture POST = read(PROC_FILE) after patch
write 0 to /sys/kernel/livepatch/livepatch_version/enabled
capture REVERT = read(PROC_FILE)

if REVERT does not contain MARKER:
    emit P3_PASS=1
else:
    emit P3_PASS=0
```

**Good path:** `P3_PASS=1`

---

## Claim boundary

| Demonstrated | Not demonstrated |
| --- | --- |
| Loadable **data-relocation** error caught by predicates | Mechanism #1 **code-relocation** / function-symbol substitution |
| `insmod` insufficient as equivalence oracle | Memory corruption / kcore forensics |
| Revert control on good module | kpatch-build vs klp-build on CVE (corpus) |
