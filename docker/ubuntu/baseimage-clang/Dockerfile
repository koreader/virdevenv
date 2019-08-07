FROM koreader/kobase:0.1.3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root
COPY clang8.list /etc/apt/sources.list.d/clang8.list
RUN apt-get remove gcc -y \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends clang-8 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 380 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-8 380 \
    && update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-8 380 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-8 380 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
