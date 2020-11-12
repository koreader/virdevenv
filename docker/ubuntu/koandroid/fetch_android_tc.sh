#!/bin/bash

echo "Downloading NDK..."
rm Makefile
wget https://raw.githubusercontent.com/koreader/koreader-base/d21a0b680832c911675daf035130a0e190e5d386/toolchain/Makefile
echo -e "y" | make android-ndk android-sdk
rm Makefile
