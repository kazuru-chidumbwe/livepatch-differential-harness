# LP-CORPUS-DIRTYPIPE SoftX QEMU forensic pack

**Pin:** Linux v5.16.10 (vulnerable Dirty Pipe tree)  
**Commit:** `528cecfa5af09631f0589efe9eacbd543c8c9db1`  
**Contract:** version marker `DIRTYPIPE-HARNESS-MARK` on `/proc/version`  
**Role:** SoftX Option A — harness reuse on a separate vulnerable pin (not v6.6.47).  
**Closed:** 16 Aug 2026 lab · synced to local harness same day  
**CAPSTONE note:** CVE-2022-0847 pipe-flag fix symbols remain the class target; this pack validates pin boot + livepatch P2/P3.

## Predicates

```
INSMOD_RC=0
P2_PASS=1
P3_PASS=0
```

## Artifacts

| File | Notes |
| --- | --- |
| `bzImage` | SHA-256 `CF5C1899E0CD0A04D16C65A5BDF24BB05E1590635E31F83C24461EFDC2390119` |
| `bzImage-ls.txt` | Lab listing |
| `livepatch-dirtypipe.ko` | Handbuild on pin |
| `handbuild.log` / `modules-prepare.log` | Build transcripts |
| `predicate-serial.log` | Full QEMU serial |
| `predicate-transcript.txt` | INSMOD/P2/P3 lines |
| `DIRTYPIPE_QEMU_DONE` | SoftX close marker |
| `pin.txt` | Tag / commit / `DIRTYPIPE_BZ_DONE` |
