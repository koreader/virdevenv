ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.4-20.04

COPY ./scripts/install_x-tools.sh .
ARG X_TOOLS_VERSION
# Use only one command to work around issue with docker:
# https://github.com/moby/moby/issues/48140
RUN for k in kindle kindle5 kindlepw2; do ./install_x-tools.sh $k $X_TOOLS_VERSION; done
