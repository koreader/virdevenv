FROM frenzie/kobase:0.0.6

USER ko

WORKDIR /home/ko
ADD ./build_kobo_tc.sh /home/ko/build_kobo_tc.sh
RUN ./build_kobo_tc.sh

RUN echo "export PATH=/home/ko/x-tools/arm-kobo-linux-gnueabihf/bin:\$PATH" >> /home/ko/.bashrc
