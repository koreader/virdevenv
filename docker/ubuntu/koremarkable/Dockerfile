ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase-18.04:0.3.0

USER ko

WORKDIR /home/ko
COPY ./build_remarkable_tc.sh /home/ko/build_remarkable_tc.sh
RUN ./build_remarkable_tc.sh
