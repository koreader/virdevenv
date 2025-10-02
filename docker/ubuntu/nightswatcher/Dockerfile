RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    unzip \
    wget \
    ;

# Install zipalign.
# NOTE: used by uber-apk-signer, which already vendors-in binaries for some platforms, but not Linux AArch64.
RUN apt-get install --no-install-recommends -y zipalign

# Install zsync.
RUN apt-get install --no-install-recommends -y zsync

# Install uber-apk-signer.
ARG JDK_VER="17"
RUN apt-get install --no-install-recommends -y openjdk-${JDK_VER}-jre-headless
ARG UBER_APK_SIGNER_VER="1.3.0"
RUN install -d /opt/uber-apk-signer
RUN wget -nv -O /opt/uber-apk-signer/uber-apk-signer.jar https://github.com/patrickfav/uber-apk-signer/releases/download/v${UBER_APK_SIGNER_VER}/uber-apk-signer-${UBER_APK_SIGNER_VER}.jar
RUN chmod 644 /opt/uber-apk-signer/uber-apk-signer.jar
RUN ln -snf /opt/uber-apk-signer/uber-apk-signer /usr/local/bin/
COPY --chmod=755 <<'EOF' /opt/uber-apk-signer/uber-apk-signer
#!/bin/sh
exec java -jar /opt/uber-apk-signer/uber-apk-signer.jar "$@"
EOF

# Install nightswatcher's other runtime dependencies.
# FIXME: replace single `requests` use in nightswatcher by a call to curl.
RUN apt-get install --no-install-recommends -y \
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

# Cleanup.
RUN apt-get remove -y --auto-remove \
    wget \
    ;

# vim: sw=4
