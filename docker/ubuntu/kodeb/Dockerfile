ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.2-20.04 AS base

FROM base AS build

USER root
RUN apt-get update
RUN apt-get upgrade -y
ARG TOOLS="chrpath"
ARG ARM_HF_TC="gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf"
ARG ARM64_TC="gcc-aarch64-linux-gnu g++-aarch64-linux-gnu"
RUN apt-get install -y --no-install-recommends ${ARM_HF_TC} ${ARM64_TC} ${TOOLS}
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /
