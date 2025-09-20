# BOOTSTRAP {{{

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get upgrade -y

# Bare minimum.
RUN apt-get install --no-install-recommends -y \
    bash-completion \
    build-essential \
    ca-certificates \
    gettext \
    git \
    less \
    neovim \
    sudo \
    unzip \
    wget \
    zstd \
    ;

# Setup root user.
COPY baseimage/bashrc /root/.bashrc

# Add dedicated user.
# NOTE: use the same UID as the one used by Github Actions to avoid permissions issues.
RUN useradd -m ${USER} -s /bin/bash -u 1001
RUN usermod -aG sudo ${USER}
RUN echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
WORKDIR ${WORKDIR}
COPY --chown=${USER} baseimage/bashrc .bashrc
USER ${USER}

# LUAJIT. {{{

ARG LUAJIT_VER="871db2c84ecefd70a850e03a6c340214a81739f0" # 2.1.1753364724
RUN git clone --branch v2.1 --depth 1 https://github.com/LuaJIT/LuaJIT.git luajit
WORKDIR luajit
RUN git fetch --depth 1 origin +${LUAJIT_VER}:refs/remotes/origin/${LUAJIT_VER}
RUN git checkout ${LUAJIT_VER}
RUN make -j"$(nproc)" amalg
RUN sudo make install
RUN luajit -v
WORKDIR ..
RUN rm -rf luajit

# }}}

# LUAROCKS. {{{

# Install luarocks.
ARG LUAROCKS_VER="3.12.2"
RUN wget https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VER}.tar.gz
RUN tar xvf luarocks-${LUAROCKS_VER}.tar.gz
WORKDIR luarocks-${LUAROCKS_VER}
RUN ./configure
RUN make
RUN sudo make install
WORKDIR ..
RUN rm -rf luarocks-${LUAROCKS_VER}*
# Configure.
RUN sudo tee -a /usr/local/etc/luarocks/config-5.1.lua <<'EOF'
wrap_bin_scripts = false
EOF

# }}}

# LUA PACKAGES. {{{

# lfs
ARG LUAFILESYSTEM_VER="1.8.0-1"
RUN sudo luarocks install luafilesystem ${LUAFILESYSTEM_VER}

# luacheck
ARG LUACHECK_VER="1.2.0-1"
RUN sudo luarocks install luacheck ${LUACHECK_VER}
RUN sudo sed -i 's/ lua$/ luajit/' $(which luacheck)

# lanes (for parallel luacheck)
ARG LANES_VER="3.17.1"
RUN wget https://github.com/LuaLanes/lanes/archive/refs/tags/v${LANES_VER}.tar.gz
RUN tar -xf v${LANES_VER}.tar.gz
RUN rm v${LANES_VER}.tar.gz
WORKDIR lanes-${LANES_VER}
# Remove `pthread_create` root specific setting (unsupported in docker).
RUN patch -p1 <<'EOF'
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
RUN luacheck --version | grep "^LuaLanes: ${LANES_VER}"
WORKDIR ..
RUN sudo rm -rf lanes-${LANES_VER}

# ldoc
ARG LDOC_VER="1.5.0-1"
RUN sudo luarocks install ldoc ${LDOC_VER}

# luacov
ARG LUACOV_VER="0.16.0-1"
RUN sudo luarocks install luacov ${LUACOV_VER}

# luacov-coveralls
ARG LUACOV_COVERALLS_VER="0.2.3-1"
RUN sudo luarocks install luacov-coveralls ${LUACOV_COVERALLS_VER}

# }}}

# OTHER. {{{

# NOTE: SDL2 is also needed for the tests.
ARG APPIMAGE_DEPS="libsdl2-2.0-0"
ARG FFI_CDECL_DEPS="gcc-11-plugin-dev"
# GLib meson build needs distutils.
ARG GLIB_DEPS="python3-distutils"
# NOTE: we don't install `gcc-multilib`, as it conflicts with cross-toolchains.
# (Cf. https://bugs.launchpad.net/ubuntu/+source/gcc-defaults/+bug/1300211)
ARG LUAJIT_DEPS="gcc-11-multilib"
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
    jq \
    libtool \
    nasm \
    ninja-build \
    openssh-client \
    p7zip-full \
    patch \
    pigz \
    pkgconf \
    python3 \
    python3-pip \
    zip \
    "
RUN sudo --preserve-env=DEBIAN_FRONTEND apt-get install --no-install-recommends -y \
    $APPIMAGE_DEPS \
    $FFI_CDECL_DEPS \
    $GLIB_DEPS \
    $LUAJIT_DEPS \
    $MISC_TOOLS \
    ;
# Fix `gcc -m32` inclusion of <asm/errno.h> et al: `/usr/include/asm` is
# normally provided by `gcc-multilib`, and link to `x86_64-linux-gnu/asm`,
# but because `/usr/include` is part of the default include directories of
# cross-toolchains too we need another location only used by the native
# toolchain: `/usr/local/include` to the rescue!
RUN sudo ln -sf /usr/include/x86_64-linux-gnu/asm /usr/local/include/asm

# ccache
ARG CCACHE_VER="4.11.3"
RUN wget -O ccache.tar.xz https://github.com/ccache/ccache/releases/download/v${CCACHE_VER}/ccache-${CCACHE_VER}-linux-x86_64.tar.xz
RUN tar xf ccache.tar.xz
RUN sudo make -C ccache-${CCACHE_VER}-linux-x86_64 install
RUN rm -rf ccache*

# cmake-lint
ARG CMAKE_LINT_VER="1.4.3"
RUN sudo python3 -m pip install cmakelint==${CMAKE_LINT_VER}

# meson
ARG MESON_VER="1.4.1"
RUN sudo python3 -m pip install meson==${MESON_VER}

# ninjatracing
ARG NINJATRACING_VER="084212eaf68f25c70579958a2ed67fb4ec2a9ca4"
RUN wget -O ninjatracing.zip https://github.com/nico/ninjatracing/archive/${NINJATRACING_VER}.zip
RUN unzip -j ninjatracing.zip '*/ninjatracing'
RUN sudo install -m755 ninjatracing /usr/local/bin/
RUN rm ninjatracing*

# shellcheck
ARG SHELLCHECK_VERSION="0.11.0"
RUN wget -O - https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz | tar --strip-components=1 -xJf - --no-anchored shellcheck
RUN sudo install -m 755 shellcheck /usr/local/bin
RUN rm shellcheck

# shfmt
ARG SHFMT_VER="3.12.0"
RUN wget -O shfmt https://github.com/mvdan/sh/releases/download/v${SHFMT_VER}/shfmt_v${SHFMT_VER}_linux_amd64
RUN sudo install -m 755 shfmt /usr/local/bin
RUN rm shfmt

# }}}

# }}}

# Cleanup.
RUN sudo apt-get remove -y --auto-remove python3-pip
RUN sudo rm -rf \
    ~${USER}/.cache \
    ~root/.cache \
    /usr/local/lib/luarocks/rocks-5.1/*/*/docs \
    /usr/share/cmake-*/Help \
    /usr/share/doc \
    /usr/share/nvim/runtime/doc \
    /var/cache/debconf/*-old \
    /var/cache/luarocks \
    ;

# vim: sw=4
