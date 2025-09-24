USER root

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends gnupg

# Install Clang.
ARG CLANG_VERSION=20
RUN wget -nv -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
COPY <<EOF /etc/apt/sources.list.d/clang${CLANG_VERSION}.list
deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-${CLANG_VERSION} main
deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-${CLANG_VERSION} main
EOF

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends clang-${CLANG_VERSION}
RUN apt-get remove --auto-remove gcc-11 -y
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-${CLANG_VERSION} 380
