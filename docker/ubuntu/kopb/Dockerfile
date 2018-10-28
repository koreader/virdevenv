FROM frenzie/kobase:0.0.10

ENV DEBIAN_FRONTEND noninteractive

USER ko
WORKDIR /home/ko
RUN git clone https://github.com/pocketbook-free/SDK_481 pocketbook-toolchain
RUN echo "export PATH=/home/ko/pocketbook-toolchain/bin:\$PATH" >> /home/ko/.bashrc
