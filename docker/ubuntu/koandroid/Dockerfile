ARG REGISTRY=docker.io
FROM scratch AS base

FROM $REGISTRY/koreader/kobase-18.04:0.3.0 AS build

USER ko
WORKDIR /home/ko

RUN sudo apt-get -qq update
RUN wget https://raw.githubusercontent.com/koreader/koreader-base/e77e2e6d9fa6b9c8aa50a25b59c6739315fafeb8/toolchain/Makefile

# Install NDK.
ARG NDK NDK_SUM
RUN make NDK_DIR="$NDK" NDK_SUM="$NDK_SUM" android-ndk
# And trim it.
RUN hardlink "$NDK"

# Install SDK.
ARG JDK
RUN sudo apt-get -qq install --no-install-recommends openjdk-$JDK-jdk-headless
ARG SDK SDK_SUM
RUN make SDK_SUM="$SDK_SUM" SDK_TARBALL="sdk-tools-linux-$SDK.zip" android-sdk

# Cleanup.
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /

USER ko
WORKDIR /home/ko

# Setup shell environment.
ARG JDK NDK
RUN echo >>.bashrc "export JAVA_HOME='/usr/lib/jvm/java-$JDK-openjdk-amd64'"
RUN echo >>.bashrc "export ANDROID_NDK_HOME='/home/ko/$NDK'"
RUN echo >>.bashrc "export ANDROID_HOME='/home/ko/android-sdk-linux'"
RUN echo >>.bashrc "export PATH=\"\$ANDROID_HOME/tools:\$PATH\""
RUN echo >>.bashrc "export PATH=\"\$ANDROID_HOME/tools/bin:\$PATH\""
RUN echo >>.bashrc "export PATH=\"\$ANDROID_HOME/build-tools/30.0.2:\$PATH\""
RUN echo >>.bashrc "export PATH=\"\$ANDROID_NDK_HOME:\$PATH\""

CMD ["bash", "-i"]
ENTRYPOINT ["bash", "-leo", "pipefail", "-c", "\"$@\"", "--"]
