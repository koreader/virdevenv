FROM phusion/baseimage:0.10.2

COPY ./bootstrap.sh /bootstrap.sh
RUN /bootstrap.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m ko
RUN usermod -aG sudo ko
RUN bash -c 'echo "ko ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)'

COPY ./install_luarocks.sh /home/ko/install_luarocks.sh
COPY .bashrc /home/ko/.bashrc
RUN chown ko:ko /home/ko/.bashrc

USER ko
WORKDIR /home/ko
RUN ./install_luarocks.sh
