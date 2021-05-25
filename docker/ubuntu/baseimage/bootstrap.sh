#!/usr/bin/env bash
set -e

# for linux-libc-dev:i386, which is needed by LuaJIT
dpkg --add-architecture i386

apt-get update
apt-get upgrade -y

ARM_SF_TC=(gcc-8-arm-linux-gnueabi g++-8-arm-linux-gnueabi)
ARM_HF_TC=(gcc-8-arm-linux-gnueabihf g++-8-arm-linux-gnueabihf)
ARM64_TC=(gcc-8-aarch64-linux-gnu g++-8-aarch64-linux-gnu)
TC_BUILD_DEPS=(gperf help2man bison texinfo flex gawk libncurses5-dev)
LIB32_GCC_DEV=(lib32gcc-8-dev libx32gcc1 libx32gomp1 libx32itm1
    libx32atomic1 libx32asan0 libx32quadmath0 libc6-x32
    libc6-dev:i386)
# libtool-bin is due to a libzmq issue, see https://github.com/zeromq/libzmq/pull/1497
# can be removed if libzmq is bumped
MISC_TOOLS=(git subversion zip unzip vim wget p7zip-full bash-completion
    sudo libtool libtool-bin)
LUAJIT_DEPS=("${LIB32_GCC_DEV[@]}")
GLIB_DEPS="gettext"
HARFBUZZ_DEPS="ragel"

echo " ------------------------------------------"
echo "| installing dependencies..."
echo "| ${LUAJIT_DEPS[*]} "
echo " ------------------------------------------"

apt-get install --no-install-recommends -y \
    "${MISC_TOOLS[@]}" \
    build-essential dpkg-dev pkg-config \
    gcc-8 cpp-8 g++-8 make automake cmake ccache \
    lua5.1 \
    ninja-build \
    patch libtool nasm autoconf2.64 \
    "${TC_BUILD_DEPS[@]}" \
    $GLIB_DEPS \
    $HARFBUZZ_DEPS \
    "${ARM_SF_TC[@]}" "${ARM_HF_TC[@]}" "${ARM64_TC[@]}" \
    "${LUAJIT_DEPS[@]}"

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8

update-alternatives --install /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc /usr/bin/arm-linux-gnueabi-gcc-8 100 --slave /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ /usr/bin/arm-linux-gnueabi-g++-8
update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc arm-linux-gnueabihf-gcc /usr/bin/arm-linux-gnueabihf-gcc-8 100 --slave /usr/bin/arm-linux-gnueabihf-g++ arm-linux-gnueabihf-g++ /usr/bin/arm-linux-gnueabihf-g++-8
update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-8 100 --slave /usr/bin/aarch64-linux-gnu-g++ aarch64-linux-gnu-g++ /usr/bin/aarch64-linux-gnu-g++-8

# compile custom xgettext with newline patch, cf. https://github.com/koreader/koreader/pull/5238#issuecomment-523794831
# upstream bug https://savannah.gnu.org/bugs/index.php?56794
GETTEXT_VER=0.21
wget http://ftpmirror.gnu.org/gettext/gettext-${GETTEXT_VER}.tar.gz
tar -xf gettext-${GETTEXT_VER}.tar.gz
pushd gettext-${GETTEXT_VER} && {
    ./configure
    make -j"$(nproc)"
    make install
    ldconfig
} && popd
rm gettext-${GETTEXT_VER}.tar.gz
rm -rf gettext-${GETTEXT_VER}
