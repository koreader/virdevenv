FROM koreader/kobase-python:0.1.5

ENV DEBIAN_FRONTEND noninteractive

USER ko
WORKDIR /home/ko
RUN git clone https://github.com/pocketbook-free/SDK_481 pocketbook-toolchain
WORKDIR /home/ko/pocketbook-toolchain
RUN rm -rf .git/ && \
    rm -rf arm-obreey-linux-gnueabi/sysroot/usr/lib/locale/
RUN echo "export PATH=/home/ko/pocketbook-toolchain/bin:\$PATH" >>/home/ko/.bashrc && \
    echo "export POCKETBOOK_TOOLCHAIN=/home/ko/pocketbook-toolchain" >>/home/ko/.bashrc && \
    echo "export SYSROOT=/home/ko/pocketbook-toolchain/arm-obreey-linux-gnueabi/sysroot" >>/home/ko/.bashrc
