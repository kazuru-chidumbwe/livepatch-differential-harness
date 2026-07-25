FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /work

RUN apt-get update && apt-get install -y \
    build-essential flex bison libssl-dev libelf-dev bc rsync \
    git python3 python3-pip cpio qemu-system-x86 qemu-utils \
    curl ca-certificates dwarves gcc-13 g++-13 \
    busybox-static file patch \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
RUN pip3 install --break-system-packages pyelftools

# Build from harness repo root: docker build -f pilot/docker/Dockerfile .
COPY . /work/

# Stage A/B entrypoints. Modules compile from source against WORK_ROOT/linux at run time.
# bzImage may be a pin artifact under pilot/build/ or produced by run-full-rebuild.sh.
RUN chmod +x pilot/docker/*.sh pilot/scripts/*.sh pilot/scripts/*.py 2>/dev/null || true

ENTRYPOINT ["/bin/bash"]
