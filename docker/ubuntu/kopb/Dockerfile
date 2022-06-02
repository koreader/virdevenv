FROM koreader/kobase:0.3.0

USER ko

WORKDIR /home/ko
COPY ./build_pb_tc.sh /home/ko/build_pb_tc.sh
RUN ./build_pb_tc.sh
