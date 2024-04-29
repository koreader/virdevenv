ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.2-20.04

COPY ./scripts/install_x-tools.sh .
ARG X_TOOLS_VERSION
RUN ./install_x-tools.sh pocketbook $X_TOOLS_VERSION
