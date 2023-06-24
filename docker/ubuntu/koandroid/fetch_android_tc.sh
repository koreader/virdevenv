#!/bin/bash
set -e

echo "Downloading NDK..."
wget https://raw.githubusercontent.com/koreader/koreader-base/d21a0b680832c911675daf035130a0e190e5d386/toolchain/Makefile
make \
  NDK_DIR='android-ndk-r23c' \
  NDK_SUM='e5053c126a47e84726d9f7173a04686a71f9a67a' \
  NDK_TARBALL='$(NDK_DIR)-linux.zip' \
  android-ndk android-sdk
rm Makefile
