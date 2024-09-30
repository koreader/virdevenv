ARG REGISTRY=docker.io
FROM $REGISTRY/phusion/baseimage:bionic-1.0.0

COPY ./baseimage-18.04/*.sh /

RUN /bootstrap.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m ko
RUN usermod -aG sudo ko
RUN bash -c 'echo "ko ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)'

COPY ./baseimage-18.04/bashrc /home/ko/.bashrc
RUN chown ko:ko /home/ko/.bashrc

USER ko
WORKDIR /home/ko
RUN /install_lint.sh
RUN /install_luarocks.sh
