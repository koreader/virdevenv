ARG REGISTRY=docker.io
FROM scratch AS base

FROM $REGISTRY/koreader/kobase:0.3.1-20.04 AS build

RUN sudo apt-get update
RUN sudo apt-get upgrade -y
RUN sudo apt-get install -y --no-install-recommends libsndio7.0
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /
USER ko
WORKDIR /home/ko
