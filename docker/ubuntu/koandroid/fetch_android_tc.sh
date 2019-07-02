#!/bin/bash

echo "Downloading NDK..."
rm Makefile
wget https://raw.githubusercontent.com/koreader/koreader-base/f07042f179127b73bc0a2d0b751fb1fdeadaac4f/toolchain/Makefile
echo -e "y" | make android-ndk android-sdk
rm Makefile
