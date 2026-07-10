# LP-CORPUS-05 — under-inclusion (mechanism #2) raw data

**Date:** 2026-07-10  
**Kernel:** v6.6.47-dirty (#6) with inline probe in `fs/proc/version.c`  
**Livepatch:** hand-build `livepatch-inline.ko` — replaces **`version_proc_show` only**

---

## Setup

`lp_inline_probe_marker()` is `static __always_inline`, called from:

| Path | proc file | Role |
| --- | --- | --- |
| **Hot** | `/proc/version` | `version_proc_show` |
| **Cold** | `/proc/version_aux` | `version_aux_proc_show` |

Replacement function `hb_version_proc_show` emits `INLINE-PATCHED`.  
`version_aux_proc_show` is **not** in `klp_funcs[]` — inlined `INLINE-ORIG` remains at the cold call site.

---

## QEMU predicate transcript

```
=== PRE ===
HOT=INLINE-ORIG
COLD=INLINE-ORIG
INSMOD_RC=0
=== POST ===
HOT=INLINE-PATCHED
COLD=INLINE-ORIG
P2_HOT=1
P2_COLD_STILL_ORIG=1
UNDER_INCLUSION_DETECTED=1
```

**dmesg:** clean livepatch transition (no fault).

---

## klp_func scope

```
hb_version_proc_show          LOCAL  (replacement)
klp_enable_patch              UND
```

Registered: `version_proc_show` **ONLY** — `version_aux_proc_show` absent.

---

## Interpretation

Classic **under-inclusion**: livepatch replaces the outlined hot-path symbol; the cold path retains the compiler-inlined pre-patch body. Load-time checks pass; hot predicate passes; **cold-path predicate exposes scope mismatch**.

This is an **intentional** under-inclusive module (documents detection). kpatch-build scope on `LP-CORPUS-05-inline-fix.patch` is a follow-up (compare changed-function set).

---

## Artifacts

- `predicate-serial.log`, `predicate-transcript.txt`
- `klp-func-scope.txt`, `livepatch-underincl.ko`
- Base kernel source: `pilot/patches/LP-CORPUS-05-version.c`
