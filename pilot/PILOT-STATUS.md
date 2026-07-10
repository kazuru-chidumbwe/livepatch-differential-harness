# Pilot execution status

**Updated:** 2026-07-10  
**Case:** LP-PILOT-01-cmdline (`cmdline_proc_show` — in-tree livepatch sample target)

## Decision gate (not yet reached)

| Step | Status | Notes |
| --- | --- | --- |
| 1. Environment pinned + container | **PARTIAL** | Kernel `v6.6.47` cloned to WSL `~/livepatch-pilot/linux` (`4c1a2d4…`); apt/qemu still needs sudo |
| 2. Pilot patch selected | **DONE** | LP-PILOT-01 — kernel `livepatch-sample` target |
| 3. Hand-built `klp_patch` | **NOT STARTED** | Needs built kernel + headers |
| 4. Validation layers | **NOT STARTED** | Needs QEMU VM booting pinned kernel |
| 5. Predicate harness | **NOT STARTED** | Workload: `cat /proc/cmdline` |
| 6. Gate deliverables | **NOT STARTED** | |

## Blockers encountered (2026-07-10)

### Lab VM `lab-host` (`lab-host`)
- **SSH timeout** from Windows host — unreachable (likely VPN/off-network).
- Historical emrtd sweeps ran here; pilot should prefer this host when reachable.

### WSL Ubuntu (local)
- **KVM available** (`/dev/kvm` present) — suitable for QEMU test target.
- **`sudo` requires password** — `apt-get install` for build-essential/qemu **blocked** (install script hung).
- **Docker Desktop** — WSL integration not enabled for Ubuntu distro.
- **Kernel clone** — in progress to `~/livepatch-pilot/linux` (WSL ext4, faster than `/mnt/d`).

## What to run when unblocked

### Option A — Lab VM (preferred)
```bash
ssh labuser@lab-host
cd ~/private-programme/repos/livepatch-differential-harness
bash pilot/scripts/00-install-host-deps.sh
bash pilot/scripts/01-fetch-kernel.sh   # uses /var/lib/livepatch-pilot
bash pilot/scripts/02-config-kernel.sh
bash pilot/scripts/03-build-kernel.sh   # ~30-90 min
# then hand-build + QEMU per pilot/README.md
```

### Option B — WSL (one-time sudo)
```bash
# Enter WSL password once:
wsl -d Ubuntu
cd "."
bash pilot/scripts/00-install-host-deps.sh
export WORK_ROOT=$HOME/livepatch-pilot
bash pilot/scripts/01-fetch-kernel.sh
bash pilot/scripts/02-config-kernel.sh
bash pilot/scripts/03-build-kernel.sh
```

## Time accounting (honest)

| Activity | Hours |
| --- | ---: |
| Pilot scaffolding + case selection | 1.5 |
| Environment probing (lab + WSL) | 0.5 |
| Kernel fetch (in progress) | TBD |
| Hand-build + validation | TBD |

## Worthiness call

**Cannot answer yet** — pilot gate requires successful hand-build + revert + perturbation on a booted pinned kernel. Infrastructure is started; execution blocked on **network to lab** or **sudo on WSL**.
