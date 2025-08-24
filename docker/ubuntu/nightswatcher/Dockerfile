ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /
RUN apt update
RUN apt-get upgrade -y
RUN apt install --no-install-recommends -y curl

# Install zsync.
RUN apt install --no-install-recommends -y zsync

# Install uber-apk-signer.
ARG JDK_VER="17"
RUN apt install --no-install-recommends -y openjdk-${JDK_VER}-jre-headless
ARG UBER_APK_SIGNER_VER="1.3.0"
RUN curl --location --output uber-apk-signer.jar https://github.com/patrickfav/uber-apk-signer/releases/download/v${UBER_APK_SIGNER_VER}/uber-apk-signer-${UBER_APK_SIGNER_VER}.jar
RUN install -d /opt/uber-apk-signer
RUN install -m644 uber-apk-signer.jar /opt/uber-apk-signer/
COPY --chmod=755 <<'EOF' /opt/uber-apk-signer/uber-apk-signer
#!/bin/sh
exec java -jar /opt/uber-apk-signer/uber-apk-signer.jar "$@"
EOF
RUN ln -snf /opt/uber-apk-signer/uber-apk-signer /usr/local/bin/
RUN rm uber-apk-signer.jar

# Install kotasync.
ARG KOTASYNC_BUILD_DEPS="\
    cmake \
    g++ \
    git \
    make \
    meson \
    ninja-build \
    patch \
"
ARG KOTASYNC_DEPS="\
    liblzma5 \
    libxxhash0 \
    libzstd1 \
    lua-dkjson \
    lua-filesystem \
    lua-socket \
"
RUN apt install --no-install-recommends -y ${KOTASYNC_BUILD_DEPS} ${KOTASYNC_DEPS}
RUN git clone --branch pr/new_ota --depth 1 https://github.com/benoit-pierre/koreader-base.git
WORKDIR koreader-base
RUN make -j"$(nproc)" CI=true fetchthirdparty
RUN make -j"$(nproc)" KODEBUG= OUTPUT_DIR=build kotasync
RUN install -m755 ./build/kotasync /usr/local/bin/
WORKDIR ..
RUN rm -rf koreader-base
RUN apt remove --autoremove -y ${KOTASYNC_BUILD_DEPS}
RUN ln -s $(gcc -dumpmachine)/lua /usr/lib/lua

# Install nightswatcher's other runtime dependencies.
# FIXME: replace single `requests` use in nightswatcher by a call to curl.
RUN apt install --no-install-recommends -y \
    curl \
    gunicorn \
    python3-falcon \
    python3-gevent \
    python3-gunicorn \
    python3-requests \
    python3-ujson \
    unzip \
    ;

# And finally the nightswatcher' script itself.
COPY --chmod=755 nightswatcher/nightswatcher.py /
RUN mkdir -p /data/ota /data/release_download /metadata

# vim: sw=4
