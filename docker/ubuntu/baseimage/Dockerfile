FROM phusion/baseimage:0.9.18

ADD ./bootstrap.sh /bootstrap.sh
RUN /bootstrap.sh
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m ko
USER ko

WORKDIR /home/ko
ADD ./install_luarocks.sh /home/ko/install_luarocks.sh
RUN ./install_luarocks.sh
ADD .bashrc /home/ko/.bashrc
