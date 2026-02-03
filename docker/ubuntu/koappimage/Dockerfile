USER root
RUN apt-get update
RUN apt-get upgrade -y
# NOTE: libx11-dev is needed to compile libxss-dummy.
RUN apt-get install -y --no-install-recommends libx11-dev
# SDL3 build dependencies.
RUN apt-get install -y --no-install-recommends \
    libdbus-1-dev \
    libdecor-0-dev \
    libdrm-dev \
    libegl1-mesa-dev \
    libgbm-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libibus-1.0-dev \
    libudev-dev \
    liburing-dev \
    libwayland-dev \
    libx11-dev \
    libxcursor-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxrandr-dev \
    libxss-dev \
    libxtst-dev \
    ;
