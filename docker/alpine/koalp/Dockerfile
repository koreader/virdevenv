# BOOTSTRAP {{{

RUN apk add sudo

# Setup root user.
COPY alpine/koalp/bashrc /root/.bashrc
RUN sed -i '/^root:/s,:/bin/sh$,:/bin/bash,' /etc/passwd

## Add dedicated user.
## NOTE: use the same UID as the one used by Github Actions to avoid permissions issues.
RUN adduser --disabled-password -s /bin/bash -u 1001 ${USER}
RUN echo "${USER} ALL=(ALL:ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
WORKDIR ${WORKDIR}
COPY --chown=${USER} alpine/koalp/bashrc .bashrc

# Mandatory.
RUN apk add autoconf automake bash ca-certificates cmake coreutils diffutils \
    file findutils g++ gcc gettext-dev git grep gzip libtool linux-headers make \
    meson nasm ninja-build patch pkgconf procps-ng sed sdl3 tar unzip wget zstd

# Optional.
RUN apk add 7zip ccache jq luajit

# Extra sugar.
RUN apk add bash-completion neovim

# OTHER. {{{

# ninjatracing
ARG NINJATRACING_VER="fc2924576c9338ff0721f539e6dfa2f3983ae2db"
RUN wget -nv -O ninjatracing.zip https://github.com/nico/ninjatracing/archive/${NINJATRACING_VER}.zip
RUN unzip -j ninjatracing.zip '*/ninjatracing'
RUN install -m755 ninjatracing /usr/local/bin/
RUN rm ninjatracing*

# ffi-cdecl
ARG FFI_CDECL_REV="42b562188aee7ae536b481aa34f49731cb1be351"
RUN wget -nv -O - https://github.com/koreader/koreader-base/archive/${FFI_CDECL_REV}.tar.gz | tar xz
WORKDIR koreader-base-${FFI_CDECL_REV}
RUN mkdir -p thirdparty/kpvcrlib/crengine/cr3gui/data/dict
RUN make -j"$(nproc)" OUTPUT_DIR=../../build -C ffi-cdecl/appimage appdir
RUN mv build/AppDir /opt/ffi-cdecl
RUN chmod og=rX -R /opt/ffi-cdecl
RUN ln -s /opt/ffi-cdecl/AppRun /usr/local/bin/ffi-cdecl
WORKDIR ..
RUN rm -rf koreader-base-*
RUN ffi-cdecl -v

# SDL3 build dependencies.
RUN apk add \
    dbus-dev \
    ibus-dev \
    libdecor-dev \
    libdrm-dev \
    libudev-zero-dev \
    libx11-dev \
    libxcursor-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxrandr-dev \
    libxscrnsaver-dev \
    libxtst-dev \
    mesa-dev \
    wayland-dev \
    ;

# }}}

# Cleanup.
RUN rm -rf \
   ~${USER}/.cache \
   ~root/.cache \
   /usr/bin/{cpack,ctest*} \
   /usr/share/cmake/Help \
   /usr/share/gir-1.0 \
   /usr/share/icons \
   ;
# Docbook stuff.
RUN apk info --contents --quiet docbook-xml docbook-xsl docbook-xsl-nons docbook-xsl-ns | env -C / xargs rm -v
# Glycin (sandboxed image library) loaders.
RUN apk info --contents --quiet glycin-image-rs glycin-svg | env -C / xargs rm -v
# OpenCL stuff.
RUN apk info --contents --quiet libclc mesa-rusticl | env -C / xargs rm -v
RUN rm /usr/lib/libRusticlOpenCL.so
# SPIR-V tools.
RUN apk info --contents --quiet spirv-tools | env -C / xargs rm -v

# vim: sw=4
