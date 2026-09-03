#!/usr/bin/env bash
# full-pipeline.3 — PRE(A)-only population scan over public/local livepatch .ko corpus.
# No runtime P2/P3; no field-rate claim.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
OUT="$ROOT/pilot/results/LP-PRE-POPULATION"
CORPUS="$OUT/ko-corpus"
LOG="$OUT/scan.log"
mkdir -p "$CORPUS" "$OUT"
: >"$LOG"

echo "PRE_POPULATION_START=$(date -u +%FT%TZ)" | tee -a "$LOG"

# 1) Collect existing livepatch-ish .ko from this harness (dedupe by sha256)
python3 - <<'PY' | tee -a "$LOG"
from pathlib import Path
import hashlib, shutil
root = Path(".")
dest = Path("pilot/results/LP-PRE-POPULATION/ko-corpus")
dest.mkdir(parents=True, exist_ok=True)
seen = set()
n = 0
patterns = [
    "pilot/handbuild/**/*.ko",
    "pilot/results/**/*.ko",
    "pilot/build/qemu/**/livepatch*.ko",
    "pilot/build/qemu/**/klp-*.ko",
    "pilot/build/qemu/**/kpatch-*.ko",
]
for pat in patterns:
    for p in root.glob(pat):
        if not p.is_file():
            continue
        # skip ordinary kernel modules under build/modules
        if "build/modules" in str(p).replace("\\", "/"):
            continue
        h = hashlib.sha256(p.read_bytes()).hexdigest()[:16]
        if h in seen:
            continue
        seen.add(h)
        name = f"{h}-{p.name}"
        shutil.copy2(p, dest / name)
        n += 1
        print(f"COLLECT {name} <- {p}")
print(f"COLLECTED_LOCAL={n}")
PY

# 2) Build OUT_OF_SCOPE stubs (shadow / callback) against primary pin for class diversity
export WORK_ROOT="${WORK_ROOT:-$HOME/livepatch-pilot}"
LINUX="${LINUX:-$WORK_ROOT/linux}"
STUB="$OUT/stubs"
mkdir -p "$STUB/shadow" "$STUB/callback"
cat >"$STUB/shadow/livepatch-shadow-stub.c" <<'C'
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/seq_file.h>
#include <linux/gfp.h>
/* Undef ref keeps klp_shadow_alloc visible to PRE(A) nm -u. */
extern void *klp_shadow_alloc(void *obj, unsigned long id, size_t size, gfp_t gfp,
			     void (*ctor)(void *, void *), void *ctor_data);
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
static void *volatile keep_shadow;
static int show(struct seq_file *m, void *v) { seq_puts(m, "SHADOW-STUB\n"); return 0; }
static struct klp_func funcs[] = { { .old_name = "version_proc_show", .new_func = show }, { } };
static struct klp_object objs[] = { { .name = NULL, .funcs = funcs }, { } };
static struct klp_patch patch = { .mod = THIS_MODULE, .objs = objs };
static int __init init(void) {
	keep_shadow = (void *)klp_shadow_alloc;
	return klp_enable_patch(&patch);
}
static void __exit exitfn(void) {}
module_init(init); module_exit(exitfn);
C
cat >"$STUB/shadow/Makefile" <<'M'
obj-m += livepatch-shadow-stub.o
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
all:
	$(MAKE) -C $(KDIR) M=$(THIS_DIR) modules
M

# Callback stub: define a callback-looking symbol name for defined_symbols path
cat >"$STUB/callback/livepatch-callback-stub.c" <<'C'
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/seq_file.h>
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
void __klp_pre_unpatch_callback_stub(void) {}
static int show(struct seq_file *m, void *v) { seq_puts(m, "CB-STUB\n"); return 0; }
static struct klp_func funcs[] = { { .old_name = "version_proc_show", .new_func = show }, { } };
static struct klp_object objs[] = { { .name = NULL, .funcs = funcs }, { } };
static struct klp_patch patch = { .mod = THIS_MODULE, .objs = objs };
static int __init init(void) { return klp_enable_patch(&patch); }
static void __exit exitfn(void) {}
module_init(init); module_exit(exitfn);
C
cat >"$STUB/callback/Makefile" <<'M'
obj-m += livepatch-callback-stub.o
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
all:
	$(MAKE) -C $(KDIR) M=$(THIS_DIR) modules
M

if [ -d "$LINUX" ]; then
  make -C "$STUB/shadow" -j"$(nproc)" KDIR="$LINUX" >>"$LOG" 2>&1 || echo "SHADOW_STUB_BUILD_FAIL" | tee -a "$LOG"
  make -C "$STUB/callback" -j"$(nproc)" KDIR="$LINUX" >>"$LOG" 2>&1 || echo "CALLBACK_STUB_BUILD_FAIL" | tee -a "$LOG"
  cp -f "$STUB/shadow/"*.ko "$CORPUS/" 2>/dev/null || true
  cp -f "$STUB/callback/"*.ko "$CORPUS/" 2>/dev/null || true
fi

# 3) Public source samples: build in-tree livepatch selftest modules if present
SELF="$LINUX/tools/testing/selftests/livepatch"
if [ -d "$SELF" ] && [ -d "$LINUX" ]; then
  echo "SELFTESTS_DIR=$SELF" | tee -a "$LOG"
  # selftests often need special make; copy any prebuilt .ko if present
  find "$SELF" -name '*.ko' -exec cp -f {} "$CORPUS/" \; 2>/dev/null || true
fi

# 4) Optional: fetch public kpatch sample objects if network allows (source only intent)
KPATCH_EX="/tmp/kpatch-examples"
if [ ! -d "$KPATCH_EX" ]; then
  git clone --depth 1 https://github.com/dynup/kpatch.git "$KPATCH_EX" >>"$LOG" 2>&1 || true
fi
find "$KPATCH_EX" -name '*.ko' 2>/dev/null | head -50 | while read -r k; do
  cp -f "$k" "$CORPUS/" || true
done

# 5) Scan
python3 - <<'PY' | tee "$OUT/population-summary.txt" | tee -a "$LOG"
from pathlib import Path
import subprocess, json, collections
root = Path("pilot/results/LP-PRE-POPULATION/ko-corpus")
rows = []
for ko in sorted(root.glob("*.ko")):
    out = subprocess.check_output(
        ["python3", "pilot/scripts/pre-revert-scan.py", str(ko)],
        text=True, errors="replace",
    )
    d = {}
    for line in out.splitlines():
        if "=" in line:
            k, v = line.split("=", 1)
            d[k] = v
    rows.append({"module": ko.name, **d})
    print(f"{ko.name}\t{d.get('PRE_CLASS','?')}\t{d.get('PRE_TRIGGER_SYMBOLS','')}")
ctr = collections.Counter(r.get("PRE_CLASS", "?") for r in rows)
print("---")
print(f"N={len(rows)}")
for k, v in sorted(ctr.items()):
    print(f"PRE_CLASS_{k}={v}")
Path("pilot/results/LP-PRE-POPULATION/population.json").write_text(
    json.dumps({"n": len(rows), "counts": dict(ctr), "rows": rows}, indent=2),
    encoding="utf-8",
)
print("WROTE population.json")
PY

echo "PRE_POPULATION_PRE_POPULATION_DONE=$(date -u +%FT%TZ)" | tee "$OUT/PRE_POPULATION_DONE.txt" | tee -a "$LOG"
