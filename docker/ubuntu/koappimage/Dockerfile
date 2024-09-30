USER root
RUN apt-get update
RUN apt-get upgrade -y
# NOTE: libx11-dev is needed to compile libxss-dummy.
RUN apt-get install -y --no-install-recommends libsndio7.0 libx11-dev
# SDL2 dependencies.
RUN apt-get install -y --no-install-recommends \
    libdbus-1-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libglu1-mesa-dev \
    libibus-1.0-dev \
    libudev-dev \
    libwayland-dev \
    libx11-dev \
    libxcursor-dev \
    libxext-dev \
    libxi-dev \
    libxinerama-dev \
    libxkbcommon-dev \
    libxrandr-dev \
    libxss-dev \
    libxt-dev \
    libxv-dev \
    libxxf86vm-dev \
    ;
