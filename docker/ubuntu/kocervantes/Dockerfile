FROM frenzie/kobase:0.0.6

USER ko

WORKDIR /home/ko
ADD ./build_cervantes_tc.sh /home/ko/build_cervantes_tc.sh
RUN ./build_cervantes_tc.sh

RUN echo "export PATH=/home/ko/x-tools/arm-cervantes-linux-gnueabi/bin:\$PATH" >> /home/ko/.bashrc
