FROM frenzie/kobase:0.0.6

USER ko

WORKDIR /home/ko
ADD ./build_kindle_tc.sh /home/ko/build_kindle_tc.sh
RUN ./build_kindle_tc.sh

RUN echo "export PATH=/home/ko/x-tools/arm-kindle-linux-gnueabi/bin:\$PATH" >> /home/ko/.bashrc
RUN echo "export PATH=/home/ko/x-tools/arm-kindle5-linux-gnueabi/bin:\$PATH" >> /home/ko/.bashrc
RUN echo "export PATH=/home/ko/x-tools/arm-kindlepw2-linux-gnueabi/bin:\$PATH" >> /home/ko/.bashrc
