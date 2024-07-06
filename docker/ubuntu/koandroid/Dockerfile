ARG REGISTRY=docker.io
FROM $REGISTRY/koreader/kobase:0.3.2-20.04 AS base

FROM base AS build

RUN sudo apt-get -qq update
RUN wget https://github.com/koreader/koreader-base/raw/b80105edceba77e28242e1311386210af1912197/toolchain/Makefile

# Install NDK.
ARG NDK NDK_SUM
RUN sudo make -C /opt -f "$PWD/Makefile" TOOLCHAIN_DIR=/opt \
  NDK_DIR="$NDK" NDK_SUM="$NDK_SUM" android-ndk

# Install SDK.
ARG JDK
RUN sudo apt-get -qq install --no-install-recommends openjdk-$JDK-jdk-headless
ARG SDK SDK_SUM
RUN sudo make -C /opt -f "$PWD/Makefile" TOOLCHAIN_DIR=/opt \
  SDK_SUM="$SDK_SUM" SDK_TARBALL="commandlinetools-linux-$SDK.zip" android-sdk

# Cleanup.
RUN rm -vrf ~/.android/cache
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base
COPY --from=build / /

# Setup shell environment.
ARG JDK NDK
RUN sudo tee -a ~ko/.bashrc /root/.bashrc <<EOF
export JAVA_HOME='/usr/lib/jvm/java-$JDK-openjdk-amd64'
export ANDROID_NDK_HOME='/opt/$NDK'
export ANDROID_HOME='/opt/android-sdk-linux'
export PATH="\$ANDROID_HOME/build-tools/30.0.2:\$PATH"
export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH"
export PATH="\$ANDROID_HOME/platform-tools:\$PATH"
export PATH="\$ANDROID_NDK_HOME:\$PATH"
EOF
