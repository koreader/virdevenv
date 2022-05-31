#!/usr/bin/env bash
set -e

# for linux-libc-dev:i386, which is needed by LuaJIT
dpkg --add-architecture i386

apt-get update
apt-get upgrade -y

ARM_SF_TC=(gcc-arm-linux-gnueabi g++-arm-linux-gnueabi)
ARM_HF_TC=(gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf)
ARM64_TC=(gcc-aarch64-linux-gnu g++-aarch64-linux-gnu)
TC_BUILD_DEPS=(gperf help2man bison texinfo flex gawk libncurses5-dev)
LIB32_GCC_DEV=(lib32gcc-8-dev libx32gcc1 libx32gomp1 libx32itm1
    libx32atomic1 libx32asan5 libx32quadmath0 libc6-x32
    libc6-dev:i386)
# libtool-bin is due to a libzmq issue, see https://github.com/zeromq/libzmq/pull/1497
# can be removed if libzmq is bumped
MISC_TOOLS=(git subversion zip unzip vim wget p7zip-full bash-completion
    sudo libtool libtool-bin)
LUAJIT_DEPS=("${LIB32_GCC_DEV[@]}")
GLIB_DEPS="gettext"
HARFBUZZ_DEPS="ragel"
APPIMAGE_DEPS=(libsdl2-2.0-0 libx11-dev)

echo " ------------------------------------------"
echo "| installing dependencies..."
echo "| ${LUAJIT_DEPS[*]} "
echo " ------------------------------------------"

apt-get install --no-install-recommends -y \
    "${MISC_TOOLS[@]}" \
    build-essential dpkg-dev pkg-config \
    gcc-10 cpp-10 g++-10 make automake cmake ccache \
    fakeroot \
    lua5.1 \
    ninja-build \
    patch libtool nasm autoconf2.64 \
    "${TC_BUILD_DEPS[@]}" \
    $GLIB_DEPS \
    $HARFBUZZ_DEPS \
    "${ARM_SF_TC[@]}" "${ARM_HF_TC[@]}" "${ARM64_TC[@]}" \
    "${LUAJIT_DEPS[@]}" \
    "${APPIMAGE_DEPS[@]}"

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 700 --slave /usr/bin/g++ g++ /usr/bin/g++-9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 800 --slave /usr/bin/g++ g++ /usr/bin/g++-10

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
