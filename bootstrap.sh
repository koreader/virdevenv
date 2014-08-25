#!/usr/bin/env bash

VG_HOME_DIR="/home/vagrant"

echo " ------------------------------------------"
echo "| installing dependencies..."
echo " ------------------------------------------"
apt-get update
apt-get install -y \
	git subversion \
	zip unzip vim ia32-libs \
	gcc-arm-linux-gnueabi g++-arm-linux-gnueabi \
	gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
	g++ make automake cmake ccache patch gettext libtool \
	autoconf2.64 \
	build-essential gcc-multilib \
	libsdl1.2-dev
