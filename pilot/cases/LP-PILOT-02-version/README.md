# LP-PILOT-02 — version_proc_show (multi-reloc hand-build)

**Role:** Tests the harness **core claim** — behavioral predicates catch **loadable** semantic divergence (not only `insmod` symbol rejection).

**Target:** `version_proc_show` (`fs/proc/version.c` @ v6.6.47)

**Workload:** `cat /proc/version`

**Expected marker:** `LP-PILOT-02 patched-by-harness`

**Relocation requirements (replacement function):**

| Kind | Symbols / sites |
| --- | --- |
| `R_X86_64_PLT32` | `strlen`, `seq_printf`, `seq_putc` |
| `R_X86_64_32S` | `.rodata.str1.1` with **distinct addends** (marker vs suffix strings) |

**Perturbation B (loadable):** swap rodata addends in built `.ko` so `insmod` succeeds but output lacks the expected marker string → **P2 fails, INSMOD_RC=0**.
