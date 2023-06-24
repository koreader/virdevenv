#!/bin/bash

NDK=android-ndk-r23c

# Hardlink duplicates (reduce size by about ~700MB).
hardlink ${NDK}

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >>~/.bashrc
echo "export ANDROID_NDK_HOME=/home/ko/${NDK}" >>./.bashrc
echo 'export ANDROID_HOME=/home/ko/android-sdk-linux' >>~/.bashrc
# shellcheck disable=SC2016
echo 'export PATH=$NDK:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$PATH' >>~/.bashrc

ANDROID_SDK_VER=30.0.2
echo "export PATH=\$ANDROID_HOME/build-tools/${ANDROID_SDK_VER}:\$PATH" >>~/.bashrc
