ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.2-20.04 AS base

FROM base AS build

USER root
RUN apt-get update
RUN apt-get upgrade -y
# NOTE: kobo-usbms' libevdev need a python interpreter for building.
RUN apt-get install -y --no-install-recommends python3-minimal
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /

COPY ./scripts/install_x-tools.sh .
ARG X_TOOLS_VERSION
RUN ./install_x-tools.sh kobo $X_TOOLS_VERSION
