#!/bin/bash

echo "Downloading NDK..."
rm Makefile
wget https://raw.githubusercontent.com/koreader/koreader-base/9135bfbe6bd2f00969a721bd79c7c67100f975d5/toolchain/Makefile
echo -e "y" | make android-ndk android-sdk
rm Makefile
