#!/usr/bin/env python3
"""Unit tests for PRE(A) revert-soundness scan."""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parent / "pre-revert-scan.py"
spec = importlib.util.spec_from_file_location("pre_revert_scan", SCRIPT)
mod = importlib.util.module_from_spec(spec)
sys.modules["pre_revert_scan"] = mod
assert spec.loader is not None
spec.loader.exec_module(mod)


def test_sound():
    with patch.object(mod, "all_symbol_names", return_value={"klp_enable_patch", "seq_printf"}), patch.object(
        mod, "strings_blob", return_value="klp_patch objs"
    ):
        r = mod.scan_ko(Path("dummy.ko"))
    assert r.pre_class == "SOUND" and r.runtime_p3_eligible


def test_shadow():
    with patch.object(mod, "all_symbol_names", return_value={"klp_shadow_alloc"}), patch.object(
        mod, "strings_blob", return_value=""
    ):
        r = mod.scan_ko(Path("dummy.ko"))
    assert r.pre_class == "OUT_OF_SCOPE" and "klp_shadow_alloc" in r.trigger_symbols


def test_callback():
    with patch.object(mod, "all_symbol_names", return_value={"__klp_pre_unpatch_callback_x"}), patch.object(
        mod, "strings_blob", return_value=""
    ):
        r = mod.scan_ko(Path("dummy.ko"))
    assert r.pre_class == "OUT_OF_SCOPE"


if __name__ == "__main__":
    test_sound()
    print("PASS test_sound")
    test_shadow()
    print("PASS test_shadow")
    test_callback()
    print("PASS test_callback")
    print("all tests passed")
