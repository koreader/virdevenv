FROM koreader/kobase:0.2.0

USER ko

WORKDIR /home/ko
COPY ./build_remarkable_tc.sh /home/ko/build_remarkable_tc.sh
RUN ./build_remarkable_tc.sh
