ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.1 AS base

FROM base AS build

RUN sudo apt-get -qq update
RUN wget https://github.com/koreader/koreader-base/raw/42504399d5c7e18adb5558f26e510a74c945b5fd/toolchain/Makefile

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

# Setup shell environment.
ARG JDK NDK
RUN echo >>.bashrc "export JAVA_HOME='/usr/lib/jvm/java-$JDK-openjdk-amd64'"
RUN echo >>.bashrc "export ANDROID_NDK_HOME='/home/ko/$NDK'"
RUN echo >>.bashrc "export ANDROID_HOME='/home/ko/android-sdk-linux'"
RUN echo >>.bashrc "export PATH=\"\$ANDROID_HOME/tools:\$PATH\""
RUN echo >>.bashrc "export PATH=\"\$ANDROID_HOME/tools/bin:\$PATH\""
RUN echo >>.bashrc "export PATH=\"\$ANDROID_HOME/build-tools/30.0.2:\$PATH\""
RUN echo >>.bashrc "export PATH=\"\$ANDROID_NDK_HOME:\$PATH\""
