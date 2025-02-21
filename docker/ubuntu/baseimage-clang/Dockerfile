USER root

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends gnupg

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
RUN apt-get remove --auto-remove gcc-9 -y
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 380
RUN update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-${CLANG_VERSION} 380
# FIXME: why does fribidi's `CC=clang CXX=clang++ ./configure` still need gcc?
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-${CLANG_VERSION} 380
