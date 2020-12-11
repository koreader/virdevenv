#!/usr/bin/env bash

# for linux-libc-dev:i386, which is needed by LuaJIT
dpkg --add-architecture i386

apt-get update

ARM_SF_TC=(gcc-arm-linux-gnueabi g++-arm-linux-gnueabi)
ARM_HF_TC=(gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf)
ARM64_TC=(gcc-aarch64-linux-gnu g++-aarch64-linux-gnu)
TC_BUILD_DEPS=(gperf help2man bison texinfo flex gawk libncurses5-dev)
LIB32_GCC_DEV=(lib32gcc-4.8-dev libx32gcc1 libx32gomp1 libx32itm1
    libx32atomic1 libx32asan0 libx32quadmath0 libc6-x32)
MISC_TOOLS=(git subversion zip unzip vim wget p7zip-full bash-completion)
LUAJIT_DEPS=("${LIB32_GCC_DEV[@]}" libc6-dev-amd64:i386)
GLIB_DEPS="gettext"

APPIMAGE_DEPS=(libsdl2-2.0-0)

echo " ------------------------------------------"
echo "| installing dependencies..."
echo "| ${LUAJIT_DEPS[*]} "
echo " ------------------------------------------"

apt-get install -y \
    "${MISC_TOOLS[@]}" \
    build-essential dpkg-dev pkg-config python3-pip \
    gcc-4.8 cpp-4.8 g++-4.8 make automake cmake ccache \
    patch libtool nasm autoconf2.64 \
    "${TC_BUILD_DEPS[@]}" \
    $GLIB_DEPS \
    "${ARM_SF_TC[@]}" "${ARM_HF_TC[@]}" "{ARM64_TC[@]}" \
    "${LUAJIT_DEPS[@]}" \
    "${APPIMAGE_DEPS[@]}" \
    libffi-dev libsdl2-dev

apt-get clean -y
apt-get autoremove -y
