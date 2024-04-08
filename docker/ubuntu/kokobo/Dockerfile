ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.1-20.04

USER ko

WORKDIR /home/ko
COPY ./scripts/install_x-tools.sh .
ARG X_TOOLS_VERSION
RUN ./install_x-tools.sh kobo $X_TOOLS_VERSION
