#!/bin/bash

echo "Downloading NDK..."
rm Makefile
wget https://raw.githubusercontent.com/koreader/koreader-base/03d3baf3d8bcbcbd60199ee41ecc5d1df66f24de/toolchain/Makefile
make android-ndk android-sdk
rm Makefile
