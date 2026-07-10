FROM ubuntu:24.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential flex bison libssl-dev libelf-dev bc rsync git \
    python3 python3-pip dwarves gcc-13 g++-13 cpio qemu-system-x86 \
    && rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
WORKDIR /work
COPY pilot/env/pins.env /work/pilot/env/pins.env
COPY pilot/config/livepatch.fragment /work/pilot/config/livepatch.fragment
# Full tree mounted at runtime; image pins toolchain only
CMD ["bash", "-lc", "gcc --version && echo pilot-toolchain-ok"]
