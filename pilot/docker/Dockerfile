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

# Prebuilt QEMU kernel + modules expected under pilot/build/ and pilot/results/
RUN chmod +x pilot/docker/run-all.sh pilot/scripts/*.sh 2>/dev/null || true

ENTRYPOINT ["/bin/bash"]
