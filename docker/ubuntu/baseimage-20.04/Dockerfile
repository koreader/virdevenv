ARG REGISTRY=docker.io
FROM scratch AS base

FROM $REGISTRY/phusion/baseimage:focal-1.2.0 AS build

# BOOTSTRAP {{{

# for linux-libc-dev:i386, which is needed by LuaJIT
RUN dpkg --add-architecture i386

RUN apt-get update
RUN apt-get upgrade -y

# Base development tools.
# libtool-bin is due to a libzmq issue, see https://github.com/zeromq/libzmq/pull/1497
# can be removed if libzmq is bumped
ARG MISC_TOOLS="git zip unzip neovim wget p7zip-full bash-completion \
    sudo libtool libtool-bin hardlink \
    "
RUN apt-get install --no-install-recommends -y \
    build-essential dpkg-dev pkg-config \
    gcc-10 cpp-10 g++-10 make automake cmake ccache \
    fakeroot \
    lua5.1 \
    ninja-build \
    patch libtool nasm autoconf2.64 \
    $MISC_TOOLS
RUN apt-get remove --auto-remove -y gcc-9 vim-tiny
RUN sudo update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-10 800 \
    --slave /usr/bin/cc cc /usr/bin/gcc-10 \
    --slave /usr/bin/c++ c++ /usr/bin/g++-10 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-10 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-10 \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-10 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-10 \
    ;

# compile custom xgettext with newline patch, cf. https://github.com/koreader/koreader/pull/5238#issuecomment-523794831
# upstream bug https://savannah.gnu.org/bugs/index.php?56794
ARG GETTEXT_VER=0.21
RUN wget http://ftpmirror.gnu.org/gettext/gettext-${GETTEXT_VER}.tar.gz
RUN tar -xf gettext-${GETTEXT_VER}.tar.gz
WORKDIR gettext-${GETTEXT_VER}
RUN ./configure --disable-dependency-tracking --disable-shared --disable-static
RUN make -j"$(nproc)"
RUN make -C gettext-tools/src/ install-strip
WORKDIR ..
RUN rm -rf gettext-${GETTEXT_VER}*

# Extra dependencies.
ARG LIB32_GCC_DEV="lib32gcc-10-dev libx32gcc1 libx32gomp1 libx32itm1 \
    libx32atomic1 libx32asan5 libx32quadmath0 libc6-x32 \
    libc6-dev:i386 \
    "
ARG LUAJIT_DEPS="$LIB32_GCC_DEV"
ARG APPIMAGE_DEPS="libsdl2-2.0-0 libx11-dev"
RUN apt-get install --no-install-recommends -y \
    $LUAJIT_DEPS \
    $APPIMAGE_DEPS

# }}}

# Create a symlink to prevent trouble finding the library in CI.
# TODO Make this more dependable in base.
RUN ln -sf /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /usr/lib/x86_64-linux-gnu/libSDL2.so

# Add dedicated user.
RUN useradd -m ko -s /bin/bash
RUN usermod -aG sudo ko
RUN echo 'ko ALL=(ALL:ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo
WORKDIR /home/ko
COPY --chown=ko bashrc .bashrc
USER ko
RUN mkdir -p local/bin
ENV PATH=/home/ko/local/bin:$PATH

# LINTERS. {{{

ARG SHELLCHECK_VERSION="v0.8.0"
ARG SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/$SHELLCHECK_VERSION/shellcheck-$SHELLCHECK_VERSION.linux.x86_64.tar.xz"
RUN curl -sSL "$SHELLCHECK_URL" | tar --strip-components=1 -C local/bin -xJf - --no-anchored shellcheck
RUN chmod +x local/bin/shellcheck

ARG SHFMT_URL="https://github.com/mvdan/sh/releases/download/v3.4.3/shfmt_v3.4.3_linux_amd64"
RUN curl -sSL "$SHFMT_URL" -o local/bin/shfmt
RUN chmod +x local/bin/shfmt

# }}}

# LUAROCKS. {{{

RUN git clone https://github.com/torch/luajit-rocks.git
WORKDIR luajit-rocks
RUN git checkout 2c7496b905f6f972673effda4884766433b7583b
RUN echo $HOME
RUN cmake . -DWITH_LUAJIT21=ON -DCMAKE_INSTALL_PREFIX="$HOME/local"
RUN make install
WORKDIR ..
RUN rm -rf luajit-rocks

COPY --chown=ko <<EOF .luarocks/config.lua
wrap_bin_scripts = false
EOF
RUN luarocks --local install luafilesystem
RUN luarocks --local install ansicolors
RUN luarocks --local install busted 2.0.0-1
RUN luarocks --local install luacov

# luasec.
RUN sudo apt-get install -y --no-install-recommends libssl-dev
# luasec doesn't automatically detect 64-bit libs
RUN luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu
RUN sudo apt-get remove -y --auto-remove libssl-dev

RUN luarocks --local install luacheck
RUN luarocks --local install lanes # for parallel luacheck
RUN luarocks --local install ldoc

# luacov-coveralls
RUN wget https://github.com/moteus/luacov-coveralls/archive/refs/heads/master.zip
RUN unzip master.zip
RUN rm master.zip
WORKDIR luacov-coveralls-master
RUN luarocks --local make rockspecs/luacov-coveralls-scm-0.rockspec
WORKDIR ..
RUN rm -rf luacov-coveralls-master

# }}}

# Cleanup.
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Final image.
FROM base
COPY --from=build / /
USER ko
WORKDIR /home/ko
