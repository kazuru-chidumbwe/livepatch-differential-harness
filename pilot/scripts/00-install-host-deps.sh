#!/usr/bin/env bash
# Install host packages for pilot (Ubuntu 24.04 / WSL)
set -euo pipefail
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential flex bison libssl-dev libelf-dev bc rsync \
  git python3 python3-pip python3-venv cpio qemu-system-x86 qemu-utils \
  debootstrap curl ca-certificates dwarves \
  gcc-13 g++-13
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 || true
gcc --version | head -1
pip3 install --user --break-system-packages pyelftools
