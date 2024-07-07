ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.4-20.04 AS base

COPY ./scripts/install_x-tools.sh .
ARG X_TOOLS_VERSION
RUN ./install_x-tools.sh kobo $X_TOOLS_VERSION
