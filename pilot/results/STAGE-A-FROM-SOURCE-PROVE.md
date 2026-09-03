# Stage A Stage A prove

- UTC: 2026-08-15T08:32:24Z
- WORK_ROOT=/opt/atlas/livepatch-pilot
- Recipe: `make -C pilot/handbuild/<case> KDIR=$WORK_ROOT/linux` (same as `pilot/docker/run-build-modules.sh`)
- Prebuilt `.ko` deleted before rebuild

```
-rw-r--r-- 1 root root 193104 2026-08-15 10:32 pilot/handbuild/LP-CORPUS-03-seqputs/livepatch-corpus03.ko
-rw-r--r-- 1 root root 193640 2026-08-15 10:32 pilot/handbuild/LP-PILOT-02/livepatch-version.ko
```
