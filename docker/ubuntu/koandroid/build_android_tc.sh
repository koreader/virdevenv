#!/bin/bash

echo "Pruning NDK to reduce image size..."
NDK=android-ndk
# only keep 9, 14 and 19, 21
rm -rf ${NDK}/platforms/android-{12,13,15,16,17,18,22,23,24}
# only keep arm
rm -rf ${NDK}/toolchains/{aarch64-linux-android-4.9,mips64el-linux-android-4.9,mipsel-linux-android-4.9,x86-4.9,x86_64-4.9}

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc
echo 'export NDK=/home/ko/android-ndk-r12b' >> ./.bashrc
echo 'export ANDROID_HOME=/home/ko/android-sdk-linux' >> ~/.bashrc
echo 'export PATH=$NDK:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$PATH' >> ~/.bashrc

source ~/.bashrc
echo -e "y" | android update sdk --no-ui --filter android-21
echo -e "y" | android update sdk --no-ui --filter android-19
