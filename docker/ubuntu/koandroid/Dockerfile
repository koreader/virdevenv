FROM houqp/kobase:0.0.3

USER root
RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y --no-install-recommends openjdk-8-jdk ant
RUN apt-get remove -y openjdk-7-jre-headless
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ko
WORKDIR /home/ko
ADD ./fetch_android_tc.sh /home/ko/fetch_android_tc.sh
RUN ./fetch_android_tc.sh
ADD ./build_android_tc.sh /home/ko/build_android_tc.sh
RUN ./build_android_tc.sh
