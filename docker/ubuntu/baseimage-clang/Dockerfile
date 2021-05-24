FROM koreader/kobase:0.1.5

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root
COPY clang10.list /etc/apt/sources.list.d/clang10.list
RUN apt-get remove gcc -y \
    && wget --progress=dot:giga -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends clang-10 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 380 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 380 \
    && update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-10 380 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-10 380 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
