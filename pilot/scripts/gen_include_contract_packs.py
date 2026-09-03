#!/usr/bin/env python3
"""Emit INCLUDE CVE contract handbuilds (version_proc_show markers; not field reproductions)."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HB = ROOT / "pilot" / "handbuild"
CASES = ROOT / "pilot" / "cases"

# Remaining INCLUDE shortlist after 52577 + 36904 already on disk.
PACKS = [
    ("CVE-2023-52578", "br_handle_frame_finish", "bridge stats"),
    ("CVE-2024-27395", "openvswitch helper", "ovs isolated helper"),
    ("CVE-2024-22705", "smb2_get_data_area_len", "ksmbd bounds"),
    ("CVE-2024-35864", "smb client bounds", "smb client"),
]

MAKEFILE = """\
obj-m += livepatch-{slug}.o

KDIR ?= $(WORK_ROOT)/linux
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

all:
\t$(MAKE) -C $(KDIR) M=$(THIS_DIR) modules

clean:
\t$(MAKE) -C $(KDIR) M=$(THIS_DIR) clean
"""

C_TMPL = """\
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/seq_file.h>

MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
MODULE_AUTHOR("Seke Kazuru");
MODULE_DESCRIPTION("LP-{cve} INCLUDE contract pack (v6.6.47); version_proc_show marker, not a field reproduction of {locus}");

static int hb_version_proc_show(struct seq_file *m, void *v)
{{
\tseq_printf(m, "{cve}-HARNESS-MARK\\n");
\treturn 0;
}}

static struct klp_func funcs[] = {{
\t{{
\t\t.old_name = "version_proc_show",
\t\t.new_func = hb_version_proc_show,
\t}},
\t{{ }}
}};

static struct klp_object objs[] = {{
\t{{
\t\t.name = NULL,
\t\t.funcs = funcs,
\t}},
\t{{ }}
}};

static struct klp_patch patch = {{
\t.mod = THIS_MODULE,
\t.objs = objs,
}};

static int livepatch_init(void)
{{
\treturn klp_enable_patch(&patch);
}}

static void livepatch_exit(void)
{{
}}

module_init(livepatch_init);
module_exit(livepatch_exit);
"""

README = """\
# LP-{cve} — {locus} INCLUDE micro-case

**Class:** INCLUDE contract pack (harness depth), **not** a field reproduction of `{locus}`.
**Pin:** Linux v6.6.47
**Oracle:** PRE(A) + marker `{cve}-HARNESS-MARK` on `/proc/version` + PRE-gated P3
**Notes:** {note}
"""


def main() -> None:
    for cve, locus, note in PACKS:
        slug = cve.lower()
        sub = f"LP-{cve}"
        hb = HB / sub
        cs = CASES / sub
        hb.mkdir(parents=True, exist_ok=True)
        cs.mkdir(parents=True, exist_ok=True)
        (hb / "Makefile").write_text(MAKEFILE.format(slug=slug), encoding="utf-8")
        (hb / f"livepatch-{slug}.c").write_text(
            C_TMPL.format(cve=cve, locus=locus), encoding="utf-8"
        )
        (cs / "README.md").write_text(
            README.format(cve=cve, locus=locus, note=note), encoding="utf-8"
        )
        (cs / "case.env").write_text(
            f"CASE_ID=LP-{cve}\nCVE={cve}\nMARKER={cve}-HARNESS-MARK\n"
            f"PROC_FILE=/proc/version\nKIND=INCLUDE_CONTRACT\n",
            encoding="utf-8",
        )
        print(f"wrote {sub}")


if __name__ == "__main__":
    main()
