# LP-PILOT-01 — cmdline_proc_show (kernel livepatch sample)

**Why this case:** Official in-tree livepatch sample — single vmlinux function, no inlining, userspace-triggerable via `/proc/cmdline`. Citable without inventing a synthetic CVE.

**Target function:** `cmdline_proc_show` (fs/proc/cmdline.c)

**Upstream reference:** `samples/livepatch/livepatch-sample.c` @ pinned kernel tag

**Workload:** `cat /proc/cmdline` — expect patched marker in output after transition

**Predicates (pilot):**

| ID | Check |
| --- | --- |
| P1 | `/proc/cmdline` read succeeds |
| P2 | Output contains livepatch sample marker post-transition |
| P3 | Revert module restores pre-patch output |

**Not in scope for pilot:** lockdep predicates, multi-pipeline ELF diff (Stage-1 comes after hand-build gate)
