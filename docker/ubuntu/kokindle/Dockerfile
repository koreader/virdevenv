ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.1-20.04

COPY ./scripts/install_x-tools.sh .
ARG X_TOOLS_VERSION
RUN ./install_x-tools.sh kindle $X_TOOLS_VERSION
RUN ./install_x-tools.sh kindle5 $X_TOOLS_VERSION
RUN ./install_x-tools.sh kindlepw2 $X_TOOLS_VERSION
