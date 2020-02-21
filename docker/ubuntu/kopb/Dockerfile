FROM koreader/kobase:0.1.6

USER ko

WORKDIR /home/ko
COPY ./build_pb_tc.sh /home/ko/build_pb_tc.sh
RUN ./build_pb_tc.sh
