ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase-18.04:0.3.0

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsdl2-2.0-0 libx11-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Create a symlink to prevent trouble finding the library in CI.
# TODO Make this more dependable in base.
RUN ln -sf /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /usr/lib/x86_64-linux-gnu/libSDL2.so

USER ko
