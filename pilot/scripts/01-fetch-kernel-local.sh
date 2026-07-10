#!/usr/bin/env bash
set -euo pipefail
REPO="."
mkdir -p "$REPO/pilot/build"
if [[ ! -d "$REPO/pilot/build/linux/.git" ]]; then
  git clone --depth 1 --branch v6.6.47 \
    https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git \
    "$REPO/pilot/build/linux"
fi
cd "$REPO/pilot/build/linux"
git rev-parse HEAD | tee "$REPO/pilot/results/kernel.commit"
ls samples/livepatch/
head -100 samples/livepatch/livepatch-sample.c
