# Patch corpus

Patches are added to `catalog.json` with:

| Field | Purpose |
| --- | --- |
| `id` | Stable identifier (e.g. `LP-PATCH-01`) |
| `source` | Path to `.patch` file or upstream CVE/fix reference |
| `subsystem` | fs, net, sched, module, etc. |
| `probe` | Name of probe script under `probes/` |
| `notes` | Applicability constraints for all build tools |

**Selection criteria (pilot):**

- self-contained function change applicable to `6.8.0-40-generic`
- buildable with all pipelines under test
- triggerable by deterministic userland or kprobe probe
- diverse code shapes across the corpus (static, inline, per-cpu, struct change, …)

Patches are **exploratory**, not claimed representative of all livepatchable fixes.
