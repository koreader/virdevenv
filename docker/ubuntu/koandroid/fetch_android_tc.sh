#!/bin/bash

echo "Downloading NDK..."
rm Makefile
wget https://raw.githubusercontent.com/koreader/koreader-base/fc019eff80e3d645335cd501c92ba751ee2f1f76/toolchain/Makefile
echo -e "y" | make android-ndk android-sdk
rm Makefile
