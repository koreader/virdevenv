FROM koreader/kobase:0.3.0

USER ko

WORKDIR /home/ko
COPY ./build_kindle_tc.sh /home/ko/build_kindle_tc.sh
RUN ./build_kindle_tc.sh
