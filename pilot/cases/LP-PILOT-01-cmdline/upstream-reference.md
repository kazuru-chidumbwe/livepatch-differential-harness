# Upstream reference (v6.6.47)

Fetched from kernel.org stable tree — **not** the hand-built artifact.

The pilot requires manually constructing equivalent `klp_func` / relocation entries
without copying this file verbatim into the hand-build deliverable.

See: `samples/livepatch/livepatch-sample.c` @ v6.6.47

Target:
- `old_name`: `cmdline_proc_show`
- `new_func`: replacement printing `this has been live patched`

Hand-build work happens in `../handbuild/` once kernel is built.
