# Pilot execution status

**Updated:** 2026-07-10 (lab reachable)  
**Case:** LP-PILOT-01-cmdline (`cmdline_proc_show` — in-tree livepatch sample target)

## Decision gate (not yet reached)

| Step | Status | Notes |
| --- | --- | --- |
| 1. Environment pinned + container | **IN PROGRESS** | Lab `lab-host`: deps installed, kernel `v6.6.47` @ `4c1a2d4…`, config OK; **kernel build running** (pid on lab) |
| 2. Pilot patch selected | **DONE** | LP-PILOT-01 — kernel `livepatch-sample` target |
| 3. Hand-built `klp_patch` | **NOT STARTED** | Needs built kernel + headers |
| 4. Validation layers | **NOT STARTED** | Needs QEMU VM booting pinned kernel |
| 5. Predicate harness | **NOT STARTED** | Workload: `cat /proc/cmdline` |
| 6. Gate deliverables | **NOT STARTED** | |

## Blockers encountered (2026-07-10)

### Lab VM `lab-host` (`lab-host`) — **REACHABLE**
- SSH OK; Ubuntu 24.04, kernel 6.8 host, gcc 13.3, KVM/QEMU installed.
- Harness synced to `~/private-programme/repos/livepatch-differential-harness`.
- `sudo` via non-interactive SSH: use `lab-lp-pilot-run.py` (password piped with `-S`).
- Kernel tree: `$HOME/livepatch-pilot/linux` (not `/var/lib` — no write permission).
- **Build:** `03-build-kernel.sh` running in background; check with `lab-lp-pilot-status.py`.

### WSL Ubuntu (fallback)
- KVM available; sudo password still required for apt.
- Partial clone on `/mnt/d/...` — prefer lab host.

## What to run next (lab)

```bash
# From Windows host:
python notes/lab-lp-pilot-status.py   # build progress
python notes/lab-lp-pilot-run.py --steps fetch  # re-fetch if needed

# After bzImage exists:
# hand-build klp_patch for LP-PILOT-01-cmdline
# QEMU boot pinned kernel → insmod → cat /proc/cmdline → revert → perturbation
```

## Time accounting (honest)

| Activity | Hours |
| --- | ---: |
| Pilot scaffolding + case selection | 1.5 |
| Environment probing (lab + WSL) | 0.5 |
| Lab setup (deps, fetch, config, build start) | 0.5 |
| Kernel build (wall clock) | ~30–90 min (in progress) |
| Hand-build + validation | TBD |

## Worthiness call

**Cannot answer yet** — pilot gate requires successful hand-build + revert + perturbation on a booted pinned kernel. Infrastructure unblocked on lab; **kernel build in flight**.
