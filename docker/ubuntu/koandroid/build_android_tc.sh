#!/bin/bash

echo "Pruning NDK to reduce image size..."
NDK=android-ndk
# only keep NDK 19
rm -rf ${NDK}/platforms/android-{12,13,14,15,16,17,18,21,22,23,24,26}
# only keep arm
rm -rf ${NDK}/toolchains/{aarch64-linux-android-4.9,mips64el-linux-android-4.9,mipsel-linux-android-4.9,x86-4.9,x86_64-4.9}

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >>~/.bashrc
echo 'export NDK=/home/ko/android-ndk-r15c' >>./.bashrc
echo 'export ANDROID_HOME=/home/ko/android-sdk-linux' >>~/.bashrc
# shellcheck disable=SC2016
echo 'export PATH=$NDK:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$PATH' >>~/.bashrc

ANDROID_SDK_VER=24.0.3
echo "export PATH=\$ANDROID_HOME/build-tools/${ANDROID_SDK_VER}:\$PATH" >>~/.bashrc
