ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase-22.04:0.3.0

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jdk python-is-python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
WORKDIR /home/ko
COPY ./fetch_android_tc.sh /home/ko/fetch_android_tc.sh
COPY ./build_android_tc.sh /home/ko/build_android_tc.sh
RUN ./fetch_android_tc.sh && \
    ./build_android_tc.sh
