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
    unzip \
    wget \
    ;

# Setup root user.
COPY bashrc /root/.bashrc

# Add dedicated user.
RUN useradd -m ko -s /bin/bash
RUN usermod -aG sudo ko
RUN echo 'ko ALL=(ALL:ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo
WORKDIR /home/ko
COPY --chown=ko bashrc .bashrc
USER ko

# compile custom xgettext with newline patch, cf. https://github.com/koreader/koreader/pull/5238#issuecomment-523794831
# upstream bug https://savannah.gnu.org/bugs/index.php?56794
ARG GETTEXT_VER="0.21"
RUN wget http://ftpmirror.gnu.org/gettext/gettext-${GETTEXT_VER}.tar.gz \
    || wget http://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VER}.tar.gz
RUN tar -xf gettext-${GETTEXT_VER}.tar.gz
WORKDIR gettext-${GETTEXT_VER}
RUN ./configure --disable-dependency-tracking --disable-shared --disable-static
RUN make -j"$(nproc)"
RUN sudo make -C gettext-tools/src/ install-strip
WORKDIR ..
RUN rm -rf gettext-${GETTEXT_VER}*

# LUAJIT. {{{

ARG LUAJIT_VERSION="2.1.0-beta3"
RUN git clone --branch v${LUAJIT_VERSION} --depth 1 https://github.com/LuaJIT/LuaJIT.git luajit
WORKDIR luajit
RUN make -j"$(nproc)" amalg
RUN sudo make install
RUN test -x /usr/local/bin/luajit || sudo ln -sv luajit-${LUAJIT_VERSION} /usr/local/bin/luajit
RUN luajit -v
WORKDIR ..
RUN rm -rf luajit

# }}}

# LUAROCKS. {{{

# Install luarocks.
ARG LUAROCKS_VERSION="3.11.0"
RUN wget https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz
RUN tar xvf luarocks-${LUAROCKS_VERSION}.tar.gz
WORKDIR luarocks-${LUAROCKS_VERSION}
RUN ./configure
RUN make
RUN sudo make install
WORKDIR ..
RUN rm -rf luarocks-${LUAROCKS_VERSION}*
# Configure.
RUN sudo tee -a /usr/local/etc/luarocks/config-5.1.lua <<\EOF
wrap_bin_scripts = false
EOF

# }}}

# LUA PACKAGES. {{{

# lfs
RUN sudo luarocks install luafilesystem

# busted
RUN sudo luarocks install busted

# luasec.
RUN sudo apt-get install -y --no-install-recommends libssl-dev
# luasec doesn't automatically detect 64-bit libs
RUN sudo luarocks install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu
RUN sudo apt-get remove -y --auto-remove libssl-dev

# luacheck
RUN sudo luarocks install luacheck
RUN sudo sed -i 's/ lua$/ luajit/' $(which luacheck)

# lanes (for parallel luacheck)
ARG LANES_VER="3.17.0"
RUN sudo luarocks install lanes
RUN wget https://github.com/LuaLanes/lanes/archive/refs/tags/v${LANES_VER}.tar.gz
RUN tar -xf v${LANES_VER}.tar.gz
RUN rm v${LANES_VER}.tar.gz
WORKDIR lanes-${LANES_VER}
# Remove `pthread_create` root specific setting (unsupported in docker).
RUN patch -p1 <<\EOF
diff --git a/src/threading.c b/src/threading.c
index 2464d03..44357cb 100644
--- a/src/threading.c
+++ b/src/threading.c
@@ -810,7 +810,7 @@ void THREAD_CREATE( THREAD_T* ref, THREAD_RETURN_T (*func)( void*), void* data,
     PT_CALL( pthread_attr_setstacksize( &a, _THREAD_STACK_SIZE));
 #endif

-    if (change_priority)
+    if (0)
     {
         struct sched_param sp;
         // "The specified scheduling parameters are only used if the scheduling
EOF
RUN sudo luarocks make lanes-${LANES_VER}-0.rockspec
# Ensure lanes module is detected by luacheck.
RUN luacheck --version | grep "^LuaLanes: ${LANES_VERSION}"
WORKDIR ..
RUN sudo rm -rf lanes-${LANES_VER}

# ldoc
RUN sudo luarocks install ldoc

# luacov
RUN sudo luarocks install luacov
RUN wget https://github.com/moteus/luacov-coveralls/archive/refs/heads/master.zip
RUN unzip master.zip
RUN rm master.zip
WORKDIR luacov-coveralls-master
RUN sudo luarocks make rockspecs/luacov-coveralls-scm-0.rockspec
WORKDIR ..
RUN rm -rf luacov-coveralls-master

# }}}

# OTHER. {{{

# NOTE: SDL2 is also needed for the tests.
ARG APPIMAGE_DEPS="libsdl2-2.0-0"
# NOTE: we don't install `gcc-multilib`, as it conflicts with cross-toolchains.
# (Cf. https://bugs.launchpad.net/ubuntu/+source/gcc-defaults/+bug/1300211)
ARG LUAJIT_DEPS="gcc-9-multilib"
ARG MISC_TOOLS="\
    autoconf2.64 \
    automake \
    chrpath \
    cmake \
    curl \
    diffstat \
    dpkg-dev \
    fakeroot \
    hardlink \
    libtool \
    nasm \
    ninja-build \
    openssh-client \
    p7zip-full \
    patch \
    pkg-config \
    python3 \
    python3-pip \
    zip \
    "
RUN sudo --preserve-env=DEBIAN_FRONTEND apt-get install --no-install-recommends -y \
    $APPIMAGE_DEPS \
    $LUAJIT_DEPS \
    $MISC_TOOLS \
    ;
# Fix `gcc -m32` inclusion of <asm/errno.h> et al: `/usr/include/asm` is
# normally provided by `gcc-multilib`, and link to `x86_64-linux-gnu/asm`,
# but because `/usr/include` is part of the default include directories of
# cross-toolchains too we need another location only used by the native
# toolchain: `/usr/local/include` to the rescue!
RUN sudo ln -sf /usr/include/x86_64-linux-gnu/asm /usr/local/include/asm
# Create a symlink to prevent trouble finding the library in CI.
# TODO: make this more dependable in base.
RUN sudo ln -sf /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /usr/lib/x86_64-linux-gnu/libSDL2.so

# ccache
ARG CCACHE_VER="4.10"
RUN wget -O ccache.tar.xz https://github.com/ccache/ccache/releases/download/v${CCACHE_VER}/ccache-${CCACHE_VER}-linux-x86_64.tar.xz
RUN tar xf ccache.tar.xz
RUN sudo make -C ccache-${CCACHE_VER}-linux-x86_64 install
RUN rm -rf ccache*

# shellcheck
ARG SHELLCHECK_VERSION="0.10.0"
RUN wget -O - https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz | tar --strip-components=1 -xJf - --no-anchored shellcheck
RUN sudo install -m 755 shellcheck /usr/local/bin
RUN rm shellcheck

# shfmt
ARG SHFMT_VER="3.8.0"
RUN wget -O shfmt https://github.com/mvdan/sh/releases/download/v${SHFMT_VER}/shfmt_v${SHFMT_VER}_linux_amd64
RUN sudo install -m 755 shfmt /usr/local/bin
RUN rm shfmt

# }}}

# }}}

# Cleanup.
RUN sudo apt-get remove -y --auto-remove python3-pip
RUN sudo apt-get clean
RUN sudo rm -rf \
    ~ko/.cache \
    ~root/.cache \
    /tmp/* \
    /usr/local/lib/luarocks/rocks-5.1/*/*/docs \
    /usr/share/cmake-*/Help \
    /usr/share/doc \
    /usr/share/nvim/runtime/doc \
    /var/cache/debconf/*-old \
    /var/cache/luarocks \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    ;

# Final image.
FROM base
COPY --from=build / /
USER ko
WORKDIR /home/ko

# vim: sw=4
