# LP-CORPUS-DIRTYPIPE package QEMU forensic pack

**Pin:** Linux v5.16.10 (vulnerable Dirty Pipe tree)  
**Commit:** `528cecfa5af09631f0589efe9eacbd543c8c9db1`  
**Contract:** version marker `DIRTYPIPE-HARNESS-MARK` on `/proc/version`  
**Role:** package Option A — harness reuse on a separate vulnerable pin (not v6.6.47).  
**Closed:** 16 Aug 2026 lab · synced to local harness same day  
**CAPSTONE note:** CVE-2022-0847 pipe-flag fix symbols remain the class target; this pack validates pin boot + livepatch P2/P3.

## Predicates (package Option A, 16 Aug 2026)

```
INSMOD_RC=0
P2_PASS=1
P3_PASS=0
```

##  PRE-gated re-run (3 Sep 2026)

Closed `DIRTYPIPE__DONE=2026-09-03T19:55:28Z` on `boma-test` (`17-run-eisej-v020.sh`). Rebuilt bzImage SHA-256 `dccbb329c49374f41fd5960711d80b4c039f2e1c37ed4e6bc5a9869feaef338b`. Transcript: `PRE_CLASS=SOUND`, `INSMOD_RC=0`, `P2_PASS=1`, `P3_PASS=1`. See `DIRTYPIPE__DONE.txt` and `pin-pregated.txt`. Not byte-identical to the package `CF5C1899…` image.

## Artifacts

| File | Notes |
| --- | --- |
| `bzImage` | SHA-256 `CF5C1899E0CD0A04D16C65A5BDF24BB05E1590635E31F83C24461EFDC2390119` |
| `bzImage-ls.txt` | Lab listing |
| `livepatch-dirtypipe.ko` | Handbuild on pin |
| `handbuild.log` / `modules-prepare.log` | Build transcripts |
| `predicate-serial.log` | Full QEMU serial |
| `predicate-transcript.txt` | INSMOD/P2/P3 lines |
| `DIRTYPIPE_QEMU_DONE` | package close marker |
| `pin.txt` | Tag / commit / `DIRTYPIPE_BZ_DONE` |
