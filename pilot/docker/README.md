# LivepatchDiff — Docker reproduction (SoftwareX)

Two-stage model: **build modules from source**, then **run predicates**. The kernel `bzImage` may be supplied as a pin artifact or rebuilt (long).

## Stage B — predicate replay (default SoftwareX clean-room)

Requires:

- `pilot/build/bzImage` (pin artifact or from Stage 0)
- Kernel tree mounted at `/work/linux` (`WORK_ROOT`) so handbuild scripts compile `.ko` from source
- Host busybox for initramfs

```bash
docker build -t livepatch-pilot:latest -f pilot/docker/Dockerfile .

docker run --rm --entrypoint /bin/bash -w /work \
  -v "$PWD:/work" \
  -v "$HOME/livepatch-pilot/linux:/work/linux:ro" \
  -e WORK_ROOT=/work/linux \
  livepatch-pilot:latest -lc 'bash pilot/docker/run-all.sh'
```

Optional explicit Stage A before predicates:

```bash
... -lc 'BUILD_FROM_SOURCE=1 bash pilot/docker/run-all.sh'
# or:
... -lc 'bash pilot/docker/run-build-modules.sh && bash pilot/docker/run-all.sh'
```

Each corpus script (`08`, `12`, `13`, …) already `make`s its handbuild directory against `WORK_ROOT/linux` before mutating/running QEMU — Stage B is not a pure “consume opaque `.ko`” path.

## Stage 0 + A + B — full from-source (kernel rebuild)

~30–60+ minutes, ~8GB disk:

```bash
docker run --rm --entrypoint /bin/bash -w /work \
  -v "$PWD:/work" \
  -v "$HOME/livepatch-pilot/linux:/work/linux" \
  -e WORK_ROOT=/work/linux \
  livepatch-pilot:latest -lc 'bash pilot/docker/run-full-rebuild.sh'
```

Uses `pilot/scripts/03-build-kernel.sh` then Stage A + Stage B.

## What `run-all.sh` runs

1. **LP-PILOT-02** — good path + loadable rodata perturbation  
2. **LP-CORPUS-01 (B1)** — klp vs kpatch predicates (needs B1 artifacts)  
3. **LP-CORPUS-02** — PLT32 reciprocal (C2)  
4. **LP-CORPUS-03** — PLT32 one-way (C3) with **structural bind oracle** + semantic P2  

C3 ground truth: `STRUCTURAL_BIND_PASS=1` from `verify-plt32-binding.py`. Coincidental `/proc` glyphs are not the oracle.

## Pins

| Component | Value |
| --- | --- |
| Kernel | v6.6.47 @ `4c1a2d4` |
| gcc | 13.x |
| kpatch-build | 0.9.11 |
| QEMU | 8.2.x |

## Artifact evaluation badge

- [x] Modules built from source against mounted kernel tree during predicate scripts  
- [x] Staged Docker entrypoints (`run-build-modules.sh`, `run-all.sh`, `run-full-rebuild.sh`)  
- [x] Structural C3 oracle (not glyph-based)  
- [ ] Zenodo DOI (pending release)  

## Operator workflow

See [`docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md) for inputs vs automatic vs manual predicate design.
