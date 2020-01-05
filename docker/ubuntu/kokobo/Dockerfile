FROM koreader/kobase:0.1.5

USER ko

WORKDIR /home/ko
COPY ./build_kobo_tc.sh /home/ko/build_kobo_tc.sh
RUN ./build_kobo_tc.sh
