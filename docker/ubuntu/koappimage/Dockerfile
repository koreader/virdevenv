ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.4-20.04 AS base

FROM base AS build

USER root
RUN apt-get update
RUN apt-get upgrade -y
# NOTE: libx11-dev is needed to compile libxss-dummy.
RUN apt-get install -y --no-install-recommends libsndio7.0 libx11-dev
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /
