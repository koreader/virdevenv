#!/usr/bin/env bash

VG_HOME_DIR="/home/vagrant"

echo " ------------------------------------------"
echo "| installing dependencies..."
echo " ------------------------------------------"
apt-get update
apt-get install -y \
	git subversion \
	zip unzip vim ia32-libs \
	g++ make automake autoconf cmake ccache patch gettext libtool \
	build-essential gcc-multilib \
	libsdl1.2-dev

# install configuration for zsh
#test -e $VG_HOME_DIR/.oh-my-zsh || ln -s /vmconfigs/oh-my-zsh $VG_HOME_DIR/.oh-my-zsh
#test -e $VG_HOME_DIR/.zshrc || ln -s /vmconfigs/.zshrc $VG_HOME_DIR/.zshrc

# switch to zsh because everyone should be using it
#chsh -s /bin/zsh vagrant

echo " ------------------------------------------"
echo "| installing arm cross compile toolchain..."
echo " ------------------------------------------"
ARM_TOOLCHAIN_DL_URL="https://bitbucket.org/houqp/kindlepdfviewer/downloads/arm-2012.03-57-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2"
ARM_TOOLCHAIN_TAR="/vmconfigs/arm-2012.03-57-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2"
ARM_TOOLCHAIN_DIR="arm-2012.03"
# untar toolchain
test -d /opt/$ARM_TOOLCHAIN_DIR || \
	((test -d $ARM_TOOLCHAIN_TAR || wget $ARM_TOOLCHAIN_DL_URL -P /vmconfigs) && \
	 (tar xf $ARM_TOOLCHAIN_TAR -C /opt))
# add toolchain to path env
grep "$ARM_TOOLCHAIN_DIR" $VG_HOME_DIR/.bashrc || \
	(echo 'PATH="/opt/arm-2012.03/bin:$PATH"' >> $VG_HOME_DIR/.bashrc)
