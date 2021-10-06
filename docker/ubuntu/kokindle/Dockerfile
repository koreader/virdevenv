FROM koreader/kobase:0.2.2

USER ko

WORKDIR /home/ko
COPY ./build_kindle_tc.sh /home/ko/build_kindle_tc.sh
RUN ./build_kindle_tc.sh
