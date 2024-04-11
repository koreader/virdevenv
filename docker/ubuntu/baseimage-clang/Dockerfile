ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.1-20.04 as base

FROM base AS build

USER root

# Install Clang.
COPY clang16.list /etc/apt/sources.list.d/clang16.list
RUN wget --progress=dot:giga -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-get update
RUN apt-get install -y --no-install-recommends clang-16
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-16 380
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-16 380
RUN update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-16 380
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-16 380

# Remove GCC.
RUN apt-get remove --auto-remove gcc gcc-9 gcc-10 -y

# Cleanup.
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /
