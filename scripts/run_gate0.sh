#!/usr/bin/env bash
# Gate 0: same-tool reproducibility (build + harness).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "gate0: NOT YET IMPLEMENTED"
echo "  Planned checks:"
echo "    1. same tool + patch, two builds → identical N(ELF)"
echo "    2. same module, two load/test runs → identical probe + dmesg hashes"
echo ""
echo "  Prerequisites: KVM image, patch corpus entry, pipeline wrapper"
exit 2
