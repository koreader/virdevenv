ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.1-20.04 as base

FROM base AS build

USER root

# Install Clang.
# NOTE: our glib version must be updated before we can switch to clang >= 15.
ARG CLANG_VERSION=14
RUN wget --progress=dot:giga -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
COPY <<EOF /etc/apt/sources.list.d/clang${CLANG_VERSION}.list
deb http://apt.llvm.org/focal/ llvm-toolchain-focal-${CLANG_VERSION} main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-${CLANG_VERSION} main
EOF
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends clang-${CLANG_VERSION}
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-${CLANG_VERSION} 380

# Remove GCC.
RUN apt-get remove --auto-remove gcc gcc-9 gcc-10 -y

# Cleanup.
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /
