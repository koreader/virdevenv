FROM frenzie/kobase-python:0.1.0

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jdk ant && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
WORKDIR /home/ko
ADD ./fetch_android_tc.sh /home/ko/fetch_android_tc.sh
ADD ./build_android_tc.sh /home/ko/build_android_tc.sh
RUN ./fetch_android_tc.sh && \
    ./build_android_tc.sh
