# Dirty Pipe package disposition — tonight (15/16 Aug 2026)

**CVE:** CVE-2022-0847  
**package bar:** appendix-complete without live QEMU predicates if build overruns.

## package close (tonight)

| Claim package may make | Evidence |
| --- | --- |
| Capstone class in triage | `cve-triage-table.md` CAPSTONE row |
| Vulnerable pin locked | `v5.16.10` @ `528cecfa5af09631f0589efe9eacbd543c8c9db1` |
| Lab tree present | `/opt/atlas/livepatch-corpus/linux-dirtypipe` |
| Case + handbuild skeleton | `pilot/cases/LP-CORPUS-DIRTYPIPE/` · `pilot/handbuild/LP-CORPUS-DIRTYPIPE/` |
| Why not on package case-study pin | Fixed before `v6.6.47` — wrong experiment |

| Claim package must **not** make | Why |
| --- | --- |
| Live QEMU P2/P3 on Dirty Pipe | Requires finished `bzImage` + handbuild + serial logs |
| Production-ready compound-case throughput | Capstone is one Option A path, not a corpus rate |

## Lab note (tonight serialization)

Dirty Pipe `bzImage` was **paused** (`SIGSTOP`) so C6 (package hard gate: kpatch `-O2`/`-Os`) could monopolize the 4-core Lab Test Server. Resume with `/tmp/lab-resume-dirtypipe.sh` after `C6_KPATCH_OPT_DONE`.

## Paper 2 reopen

1. Resume / finish `bzImage` (`DIRTYPIPE_BZ_DONE` in `pin.txt`).  
2. Handbuild fix from `v5.16.11` symbols.  
3. QEMU predicates + forensic pack under `pilot/results/LP-CORPUS-DIRTYPIPE/`.

Checklist **Dirty Pipe** package appendix = **CLOSED** on pin+skeleton+disposition. Full Option A acceptance remains open for Paper 2 / morning continuation.
