COPY ./baseimage-22.04/*.sh /

RUN /bootstrap.sh

# Create a symlink to prevent trouble finding the library in CI.
# TODO Make this more dependable in base.
#RUN ln -sf /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /usr/lib/x86_64-linux-gnu/libSDL2.so

RUN useradd -m ko
RUN usermod -aG sudo ko
RUN bash -c 'echo "ko ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)'

COPY ./baseimage-22.04/bashrc /home/ko/.bashrc
RUN chown ko:ko /home/ko/.bashrc

USER ko
WORKDIR /home/ko
RUN /install_lint.sh
RUN /install_luarocks.sh
