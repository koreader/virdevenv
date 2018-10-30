FROM phusion/baseimage:0.10.2

ADD ./bootstrap.sh /bootstrap.sh
RUN /bootstrap.sh
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m ko
RUN usermod -aG sudo ko
RUN bash -c 'echo "ko ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)'

ADD ./install_luarocks.sh /home/ko/install_luarocks.sh
ADD .bashrc /home/ko/.bashrc
RUN chown ko:ko /home/ko/.bashrc

USER ko
WORKDIR /home/ko
RUN ./install_luarocks.sh
