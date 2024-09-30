RUN sudo apt-get -qq update
RUN wget https://github.com/koreader/koreader-base/raw/4e2c7afb94cb11c9eaa293c2285ed9950118077c/toolchain/Makefile

# Install NDK.
ARG NDK NDK_SUM
RUN sudo make -C /opt -f "$PWD/Makefile" TOOLCHAIN_DIR=/opt \
  NDK_DIR="$NDK" NDK_SUM="$NDK_SUM" android-ndk
RUN sudo bash -e <<EOF
  cd /opt/$NDK
  rm -vrf prebuilt/android-*
  rm -vrf shader-tools simpleperf
  rm -vrf sources/third_party
  rm -vrf toolchains/renderscript
  pushd toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib
  rm -vrf aarch64-linux-android/2[^1]*
  rm -vrf aarch64-linux-android/[3-9]*
  rm -vrf arm-linux-androideabi/1[^8]*
  rm -vrf arm-linux-androideabi/[2-9]*
  rm -vrf i686-linux-android/1[^8]
  rm -vrf i686-linux-android/[2-9]*
  rm -vrf x86_64-linux-android/2[^1]*
  rm -vrf x86_64-linux-android/[3-9]*
  popd
  find . -name 'libomp.*' -print0 | xargs -0 rm -v
  find . -name 'libFuzzer.*' -print0 | xargs -0 rm -v
  find . -name 'libclang_rt.*' -print0 | /usr/bin/grep -E --null-data '/libclang_rt\.(\w+san|fuzzer|profile|scudo|stats)' | xargs -0 rm -v
  pushd toolchains/llvm/prebuilt/linux-x86_64
  rm bin/clang-{check,format,tidy*}
  strip --strip-unneeded lib64/liblldb*
EOF

# Install SDK.
ARG JDK
# NOTE: add `ttf-bitstream-vera` so the bigger `fonts-dejavu-core` package does not get installed.
RUN sudo apt-get -qq install --no-install-recommends ttf-bitstream-vera openjdk-$JDK-jdk-headless
ARG SDK SDK_SUM
RUN sudo make -C /opt -f "$PWD/Makefile" TOOLCHAIN_DIR=/opt \
  SDK_SUM="$SDK_SUM" SDK_TARBALL="commandlinetools-linux-$SDK.zip" android-sdk
RUN sudo hardlink /opt/android-sdk-linux

# Since we use the host clang compiler provided by the NDK, we do not
# need gcc-multilib / g++, and only keep some of their dependencies.
RUN apt-cache depends --important gcc-9-multilib \
  | sed -n '/^ *Depends: \(.*\)$/{s//\1/;/^gcc/d;p}' \
  | xargs sudo apt-mark manual
RUN sudo apt-get autoremove -y g++ gcc-9-multilib
# We also don't need SDL2.
RUN sudo apt-get autoremove -y libsdl2-2.0-0

# Install uber-apk-signer.
ARG UBER_APK_SIGNER_VER="1.3.0"
RUN wget -O uber-apk-signer.jar https://github.com/patrickfav/uber-apk-signer/releases/download/v${UBER_APK_SIGNER_VER}/uber-apk-signer-${UBER_APK_SIGNER_VER}.jar
RUN sudo install -d /opt/uber-apk-signer
RUN sudo install -m644 uber-apk-signer.jar /opt/uber-apk-signer/
COPY --chmod=755 <<'EOF' /opt/uber-apk-signer/uber-apk-signer
#!/bin/sh
exec java -jar /opt/uber-apk-signer/uber-apk-signer.jar "$@"
EOF
RUN sudo ln -snfr /opt/uber-apk-signer/uber-apk-signer /usr/local/bin/
RUN rm uber-apk-signer.jar

# Cleanup.
RUN rm -vrf ~/.android/cache
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
