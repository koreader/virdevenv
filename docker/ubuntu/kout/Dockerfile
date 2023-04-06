ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.2.0

USER root
RUN add-apt-repository ppa:bhdouglass/clickable \
    && apt-get update \
    && apt-get install -y --no-install-recommends clickable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
