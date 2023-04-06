ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root
COPY clang16.list /etc/apt/sources.list.d/clang16.list
RUN apt-get remove gcc gcc-9 gcc-10 -y \
    && wget --progress=dot:giga -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends libtool-bin clang-16 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-16 380 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-16 380 \
    && update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-16 380 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-16 380 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
