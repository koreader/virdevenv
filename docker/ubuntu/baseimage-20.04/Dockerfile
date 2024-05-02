ARG REGISTRY=docker.io
FROM scratch AS base

FROM $REGISTRY/ubuntu:focal AS build

# BOOTSTRAP {{{

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get upgrade -y

# Bare minimum for installing gettext, our LUA
# environment, and setting up a dedicated user.
RUN apt-get install --no-install-recommends -y \
    bash-completion \
    build-essential \
    ca-certificates \
    git \
    less \
    neovim \
    sudo \
    wget \
    ;

# Add dedicated user.
RUN useradd -m ko -s /bin/bash
RUN usermod -aG sudo ko
RUN echo 'ko ALL=(ALL:ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo
WORKDIR /home/ko
COPY --chown=ko bashrc .bashrc
USER ko
RUN mkdir -p local/bin
ENV PATH=/home/ko/local/bin:$PATH

# compile custom xgettext with newline patch, cf. https://github.com/koreader/koreader/pull/5238#issuecomment-523794831
# upstream bug https://savannah.gnu.org/bugs/index.php?56794
ARG GETTEXT_VER=0.21
RUN wget http://ftpmirror.gnu.org/gettext/gettext-${GETTEXT_VER}.tar.gz
RUN tar -xf gettext-${GETTEXT_VER}.tar.gz
WORKDIR gettext-${GETTEXT_VER}
RUN ./configure --disable-dependency-tracking --disable-shared --disable-static
RUN make -j"$(nproc)"
RUN sudo make -C gettext-tools/src/ install-strip
WORKDIR ..
RUN rm -rf gettext-${GETTEXT_VER}*

# LINTERS. {{{

ARG SHELLCHECK_VERSION="v0.8.0"
ARG SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/$SHELLCHECK_VERSION/shellcheck-$SHELLCHECK_VERSION.linux.x86_64.tar.xz"
RUN wget -O - "$SHELLCHECK_URL" | tar --strip-components=1 -xJf - --no-anchored shellcheck
RUN sudo install -m 755 shellcheck /usr/local/bin
RUN rm shellcheck

ARG SHFMT_URL="https://github.com/mvdan/sh/releases/download/v3.4.3/shfmt_v3.4.3_linux_amd64"
RUN wget -O shfmt "$SHFMT_URL"
RUN sudo install -m 755 shfmt /usr/local/bin
RUN rm shfmt

# }}}

# LUAJIT. {{{

ARG LUAJIT_VERSION=2.1.0-beta3
RUN git clone --branch v${LUAJIT_VERSION} --depth 1 https://github.com/LuaJIT/LuaJIT.git luajit
WORKDIR luajit
RUN make -j"$(nproc)" amalg
RUN sudo make install
RUN test -x /usr/local/bin/luajit || sudo ln -sv luajit-${LUAJIT_VERSION} /usr/local/bin/luajit
RUN luajit -v
WORKDIR ..
RUN rm -rf luajit

# }}}

RUN sudo apt-get install --no-install-recommends -y unzip

# LUAROCKS. {{{

# Install luarocks.
ARG LUAROCKS_VERSION=3.11.0
RUN wget https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz
RUN tar xvf luarocks-${LUAROCKS_VERSION}.tar.gz
WORKDIR luarocks-${LUAROCKS_VERSION}
RUN ./configure
RUN make
RUN sudo make install
WORKDIR ..
RUN rm -rf luarocks-${LUAROCKS_VERSION}*
# Configure.
RUN mkdir -p ~/.luarocks
RUN tee -a ~/.luarocks/config-5.1.lua <<EOF
local_by_default = true
wrap_bin_scripts = false
EOF

# lfs
RUN luarocks install luafilesystem

# busted
RUN luarocks install ansicolors
RUN luarocks install busted

# luasec.
RUN sudo apt-get install -y --no-install-recommends libssl-dev
# luasec doesn't automatically detect 64-bit libs
RUN luarocks install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu
RUN sudo apt-get remove -y --auto-remove libssl-dev

# luacheck
RUN luarocks install luacheck
RUN eval "$(luarocks path)" && sed -i 's/ lua$/ luajit/' $(which luacheck)

# lanes (for parallel luacheck)
RUN luarocks install lanes
# Ensure lanes module is detected by luacheck.
RUN eval "$(luarocks path)" && luacheck --version | grep "^LuaLanes: ${LANES_VERSION}"

# ldoc
RUN luarocks install ldoc

# luacov
RUN luarocks install luacov
RUN wget https://github.com/moteus/luacov-coveralls/archive/refs/heads/master.zip
RUN unzip master.zip
RUN rm master.zip
WORKDIR luacov-coveralls-master
RUN luarocks make rockspecs/luacov-coveralls-scm-0.rockspec
WORKDIR ..
RUN rm -rf luacov-coveralls-master

# }}}

# Other development dependencies / tools.
# NOTE: libtool-bin is due to a libzmq issue, see https://github.com/zeromq/libzmq/pull/1497
# (can be removed if libzmq is bumped or the build switched from autotools to cmake).
ARG MISC_TOOLS="\
    autoconf2.64 \
    automake \
    ccache \
    cmake \
    curl \
    diffstat \
    dpkg-dev \
    fakeroot \
    hardlink \
    libtool \
    libtool-bin \
    nasm \
    ninja-build \
    openssh-client \
    p7zip-full \
    patch \
    pkg-config \
    unzip \
    zip \
    "
# Extra dependencies.
ARG LUAJIT_DEPS="gcc-multilib"
# NOTE: SDL2 is also needed for the tests.
ARG APPIMAGE_DEPS="libsdl2-2.0-0"
RUN sudo --preserve-env=DEBIAN_FRONTEND apt-get install --no-install-recommends -y \
    $LUAJIT_DEPS \
    $APPIMAGE_DEPS \
    $MISC_TOOLS \
    ;
# Create a symlink to prevent trouble finding the library in CI.
# TODO: make this more dependable in base.
RUN sudo ln -sf /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /usr/lib/x86_64-linux-gnu/libSDL2.so

# }}}

# Cleanup.
RUN rm -vrf ~/.cache
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Final image.
FROM base
COPY --from=build / /
USER ko
WORKDIR /home/ko

# vim: sw=4
