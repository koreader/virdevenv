WORKDIR /
RUN apk update

# Install zsync.
ARG ZSYNC_VERSION="0.6.3"
ARG ZSYNC_BUILD_DEPS="\
    gcc \
    make \
    musl-dev \
    patch \
"
RUN apk add ${ZSYNC_BUILD_DEPS}
RUN wget https://zsync.moria.org.uk/download/zsync-${ZSYNC_VERSION}.tar.bz2
RUN tar xf zsync-${ZSYNC_VERSION}.tar.bz2
WORKDIR zsync-${ZSYNC_VERSION}
RUN patch -p1 <<'EOF'
--- a/libzsync/sha1.c
+++ b/libzsync/sha1.c
@@ -21,6 +21,7 @@
 #endif /* LIBC_SCCS and not lint */

 #include <sys/param.h>
+#include <sys/stat.h>
 #include <stdint.h>
 #include <string.h>
 #include "sha1.h"
EOF
RUN ./configure
RUN make -j"$(nproc)"
RUN make install
WORKDIR ..
RUN rm -rf zsync-*

# Install uber-apk-signer.
ARG JDK_VER="17"
RUN apk add openjdk${JDK_VER}-jre-headless
ARG UBER_APK_SIGNER_VER="1.3.0"
RUN wget -O uber-apk-signer.jar https://github.com/patrickfav/uber-apk-signer/releases/download/v${UBER_APK_SIGNER_VER}/uber-apk-signer-${UBER_APK_SIGNER_VER}.jar
RUN install -d /opt/uber-apk-signer
RUN install -m644 uber-apk-signer.jar /opt/uber-apk-signer/
COPY --chmod=755 <<'EOF' /opt/uber-apk-signer/uber-apk-signer
#!/bin/sh
exec java -jar /opt/uber-apk-signer/uber-apk-signer.jar "$@"
EOF
RUN ln -snf /opt/uber-apk-signer/uber-apk-signer /usr/local/bin/
RUN rm uber-apk-signer.jar

# Install nightswatcher's other runtime dependencies.
RUN apk add \
    curl \
    py3-falcon \
    py3-gevent \
    py3-gunicorn \
    py3-requests \
    py3-ujson \
    unzip \
    ;

# And finally the nightswatcher' script itself.
ARG NIGHTSWATCHER_VERSION
RUN echo wget https://github.com/koreader/koreader-misc/raw/${NIGHTSWATCHER_VERSION}/nightswatcher/nightswatcher.py
RUN wget https://github.com/koreader/koreader-misc/raw/${NIGHTSWATCHER_VERSION}/nightswatcher/nightswatcher.py
RUN chmod +x nightswatcher.py
RUN mkdir -p data/ota data/release_download metadata
RUN ln -s /home/ko/data /data
RUN ln -s /home/ko/metadata /metadata

# Cleanup.
RUN apk del ${ZSYNC_BUILD_DEPS}

# vim: sw=4
