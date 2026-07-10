# LP-PILOT-01 gate deliverables (§4 + ordered next steps)

**Date:** 2026-07-10  
**Case:** LP-PILOT-01-cmdline (`cmdline_proc_show`)  
**Pinned kernel:** `v6.6.47` @ `4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7`  
**Host:** `lab-host` (lab VM) + QEMU/KVM  
**Status:** **PILOT GATE CLOSED** — methodology buildable; corpus may proceed per depth-first plan.

---

## 1. Environment pins

| Item | Value |
| --- | --- |
| Kernel tag | `v6.6.47` |
| Kernel commit | `4c1a2d4cd9a5b6c55739a80c5b9efbca322adad7` |
| `bzImage` SHA-256 | `3f1cc9620356b32219a0a4ed77e76003612bbfeaa2cb57d878998ac43a21b96f` |
| `vmlinux` SHA-256 | `07d131f493d4ee6b86ca970df5a272c6ff1e7fa82b1cb11aee118ba062ad170a` |
| `.config` SHA-256 | `07d81be1b60aff07c9f36fa0b233e38ee44b79ba095600c516be5aaa9468752d` |
| GCC | 13.3.0 (Ubuntu 24.04) |
| Config highlights | `CONFIG_LIVEPATCH=y`, `CONFIG_KCOV=y`, `CONFIG_DEBUG_INFO=y` |

Artifacts: `pilot/results/kernel.commit`, `kernel.config`, `kernel.sha256`, `kernel.build.log`

---

## 2. §4 pilot deliverables

| Deliverable | Result | Evidence |
| --- | --- | --- |
| Hand-built `klp_patch` source | **PASS** | `pilot/handbuild/LP-PILOT-01/livepatch-cmdline.c` |
| Full relocation table + derivation | **PASS** | `pilot/handbuild/LP-PILOT-01/relocation-table.md`, `pilot/results/relocation-table.txt` |
| Iteration count to working `insmod` | **1** | `pilot/results/handbuild-iterations.txt` |
| Behavioral check | **PASS** | `P2_PASS=1` — `/proc/cmdline` shows `this has been live patched` |
| Revert-and-retest | **PASS** | `P3_PASS=1` — sysfs disable restores original cmdline |
| Perturbation sanity | **PASS** | Wrong-symbol module: `INSMOD_RC=1`, `P2_PASS=0` — `pilot/results/perturbation-sanity.txt` |

### Key relocation tuples (vmlinux-facing, normalized)

Derivation: `readelf -r livepatch-cmdline.ko` on hand-built module @ pinned commit.

| objname | section | r_offset | type | symbol | addend |
| --- | --- | --- | --- | --- | --- |
| vmlinux | `.rela.text` | `0x34` | `R_X86_64_PLT32` | `seq_printf` | `-4` |
| vmlinux | `.rela.text` | `0x28` | `R_X86_64_32S` | `.rodata.str1.1` | `0` |
| vmlinux | `.rela.text` | `0x2f` | `R_X86_64_32S` | `.rodata.str1.1` | `0x1b` |
| vmlinux | `.rela.init.text` | `0x26` | `R_X86_64_PLT32` | `klp_enable_patch` | `-4` |

Full dump: 6 `.rela.text` entries + standard module metadata relocs (see relocation-table files).

### Validation transcript (excerpt)

```
=== PRE_PATCH ===
console=ttyS0 panic=1 nokaslr init=/init
=== POST_PATCH ===
this has been live patched
P2_PASS=1
=== POST_REVERT ===
console=ttyS0 panic=1 nokaslr init=/init
P3_PASS=1
```

Source: `pilot/results/validation.log`, `pilot/results/qemu-serial.log`

---

## 3. SUSE `kgraft-patch` pipeline check (≈5 min)

**Verdict: NOT an independent build pipeline — exclude from §9 pipelines under test.**

| Tool | Role | Independent binary-diff builder? |
| --- | --- | --- |
| Legacy `kgraft-patch` / `kernel-livepatch` | RPM packaging + `register-patches.sh` aggregation of hand-written subpatches | **No** — orchestration/wrapper around upstream `klp_*` API |
| SUSE `klp-build` | CVE/codestream setup, `klp-ccp` extract, IBS remote build | **Yes** — distinct from `kpatch-build` / upstream `scripts/livepatch/klp-build` |
| `kpatch-build` | `create-diff-object` binary diff | **Yes** (legacy) |
| Upstream `klp-build` (6.19+) | `objtool klp` in-tree | **Yes** (successor) |

**Paper pipelines (locked):** `kpatch-build`, upstream `klp-build`. SUSE `klp-build` noted as vendor variant for qualitative discussion only unless IBS-reproduced in lab.

Detail: [`pilot/results/kgraft-patch-pipeline-check.md`](results/kgraft-patch-pipeline-check.md)

---

## 4. CVE triage (pinned LTS window)

**Window:** `linux-6.6.y` fixes with published date **2023-10-01 → 2024-12-31**, evaluated against pin **`v6.6.47`**.  
**Annotator:** single (Seke Kazuru) — cross-check not performed.  
**Method:** NVD keyword corpus + commit-message heuristics; bounded sample (n=20).

Detail: [`pilot/results/cve-triage-table.md`](results/cve-triage-table.md)

---

## 5. First concrete predicate table (LP-PILOT-01)

**Lockdep vs custom BPF decision (made concrete):**

| Mechanism | LP-PILOT-01 decision | Rationale |
| --- | --- | --- |
| **lockdep** | **Not used** | `cmdline_proc_show` is a lock-free seq_file show handler; no `lockdep` classes to import |
| **Custom BPF kprobes** | **Deferred** | User-visible `/proc/cmdline` output is sufficient trace surface; BPF adds verifier/attach complexity without coverage gain for this case |
| **Userspace output diff** | **Primary** | P1–P3 on `cat /proc/cmdline` — matches trace-equivalence definition for this workload |

Detail: [`pilot/results/predicate-table.md`](results/predicate-table.md)

**Coverage bound (pilot):** behavioral predicates only; **kcov % not measured** in QEMU gate run (CONFIG_KCOV enabled in kernel build for downstream corpus).

---

## 6. Time accounting

| Activity | Hours |
| --- | ---: |
| Pilot scaffolding + case selection (prior) | 1.5 |
| Environment probing (lab + WSL) | 0.5 |
| Lab deps + kernel build (wall clock ~25 min active) | 0.5 |
| Hand-build + QEMU validation + perturbation | 0.75 |
| Deliverable tables + gate doc | 0.75 |
| **Total to gate close** | **4.0** |

---

## 7. Worthiness call

**PROCEED.** Hand-built ground truth for a trivial single-function fix required **1 compile iteration** and passed behavioral, revert, and perturbation controls on the pinned kernel in QEMU. Methodology is **buildable**; depth-first corpus (micro-cases → Dirty Pipe capstone) may be scheduled.

**Residual risks (stated):**

- Hand-built modules are **not reusable** across kernel commits.
- Pilot predicates are **coverage-bounded** (no kcov %, no lockdep, no multi-pipeline ELF diff yet).
- CVE triage is a **bounded sample**, not exhaustive 6.6.y enumeration.

---

## 8. File index

| Path | Contents |
| --- | --- |
| `pilot/handbuild/LP-PILOT-01/livepatch-cmdline.c` | Hand-built source |
| `pilot/handbuild/LP-PILOT-01/relocation-table.md` | Relocation derivation |
| `pilot/results/handbuild-iterations.txt` | Iteration count |
| `pilot/results/validation.log` | Behavioral + revert |
| `pilot/results/perturbation-sanity.txt` | Perturbation control |
| `pilot/results/predicate-table.md` | Predicate harness v1 |
| `pilot/results/cve-triage-table.md` | Corpus gate triage |
| `pilot/results/kgraft-patch-pipeline-check.md` | Pipeline inclusion decision |
| `pilot/scripts/04-handbuild.sh` … `07-perturbation-sanity.sh` | Repro scripts |
