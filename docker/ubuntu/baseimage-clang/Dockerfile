FROM frenzie/kobase:0.1.2

USER root
COPY clang7.list /etc/apt/sources.list.d/clang7.list
RUN apt-get remove gcc -y \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends clang-7 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-7 380 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
