# Livepatch pilot — reproducible predicate runner

Boots a pinned QEMU kernel and runs the corpus predicate suite against
prebuilt livepatch modules. Full kernel rebuild is optional (see below).

## Quick start

```bash
docker build -t livepatch-pilot:latest -f pilot/docker/Dockerfile .
docker run --rm -it livepatch-pilot:latest ./run-all.sh
```

Expected output: INSMOD/P2/P3 lines for PILOT-02, C1 cross-pipeline, and mechanism-#1 triptych summaries.

## What `run-all.sh` runs

1. **Gate checks** — `bzImage`, `vmlinux` hash vs `pilot/env/pins.env`
2. **LP-PILOT-02** — good path + loadable rodata perturbation (if `.ko` present)
3. **LP-CORPUS-01** — klp vs kpatch predicates (if artifacts present)
4. **LP-CORPUS-02/03** — PLT32 mutant transcripts (if present)

Scripts invoked from `/work/pilot/scripts/` inside the container.

## Full reproduction (kernel rebuild + kpatch-build)

Requires `~8GB` disk and `~30–60 min` on a 4-core host:

```bash
docker run --rm -it -v "$HOME/livepatch-pilot/linux:/work/linux:ro" \
  livepatch-pilot:latest ./run-full-rebuild.sh
```

Mount your cloned `v6.6.47` tree at `/work/linux`. See `pilot/scripts/03-build-kernel.sh`.

## Pins

| Component | Value |
| --- | --- |
| Kernel | v6.6.47 @ `4c1a2d4` |
| gcc | 13.x |
| kpatch-build | 0.9.11 |
| QEMU | 8.2.x |

## Artifact evaluation badge

- [x] Single-command predicate replay (`./run-all.sh`)
- [ ] Zenodo DOI (pending release)
- [ ] Full unattended kernel rebuild in container (optional path documented)
