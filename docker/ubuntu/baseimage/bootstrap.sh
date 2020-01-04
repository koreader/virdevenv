#!/usr/bin/env bash
set -e

# for linux-libc-dev:i386, which is needed by LuaJIT
dpkg --add-architecture i386

apt-get update

ARM_SF_TC=(gcc-arm-linux-gnueabi g++-arm-linux-gnueabi)
ARM_HF_TC=(gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf)
TC_BUILD_DEPS=(gperf help2man bison texinfo flex gawk libncurses5-dev)
LIB32_GCC_DEV=(lib32gcc-5-dev libx32gcc1 libx32gomp1 libx32itm1
    libx32atomic1 libx32asan0 libx32quadmath0 libc6-x32)
# libtool-bin is due to a libzmq issue, see https://github.com/zeromq/libzmq/pull/1497
# can be removed if libzmq is bumped
MISC_TOOLS=(git subversion zip unzip vim wget p7zip-full bash-completion
    sudo libtool libtool-bin)
LUAJIT_DEPS=("${LIB32_GCC_DEV[@]}" libc6-dev-amd64:i386)
GLIB_DEPS="gettext"
HARFBUZZ_DEPS="ragel"

echo " ------------------------------------------"
echo "| installing dependencies..."
echo "| ${LUAJIT_DEPS[*]} "
echo " ------------------------------------------"

apt-get install -y \
    "${MISC_TOOLS[@]}" \
    build-essential dpkg-dev pkg-config python3-pip \
    gcc-5 cpp-5 g++-5 make automake cmake ccache \
    ninja-build \
    patch libtool nasm autoconf2.64 \
    "${TC_BUILD_DEPS[@]}" \
    $GLIB_DEPS \
    $HARFBUZZ_DEPS \
    "${ARM_SF_TC[@]}" "${ARM_HF_TC[@]}" \
    "${LUAJIT_DEPS[@]}"

# --upgrade to prevent urllib3 errors
pip3 install transifex-client --upgrade

# compile custom xgettext with newline patch, cf. https://github.com/koreader/koreader/pull/5238#issuecomment-523794831
# upstream bug https://savannah.gnu.org/bugs/index.php?56794
GETTEXT_VER=0.20.1
wget http://ftpmirror.gnu.org/gettext/gettext-${GETTEXT_VER}.tar.gz
tar -xf gettext-${GETTEXT_VER}.tar.gz
pushd gettext-${GETTEXT_VER} && {
    wget -O ignore-first-newline-of-lua-multiline-string.patch https://savannah.gnu.org/bugs/download.php?file_id=47379
    patch -p1 <ignore-first-newline-of-lua-multiline-string.patch
    ./configure
    make -j"$(nproc)"
    make install
    ldconfig
} && popd
rm gettext-${GETTEXT_VER}.tar.gz
rm -rf gettext-${GETTEXT_VER}
