#!/usr/bin/env bash

VG_HOME_DIR="/home/vagrant"

cd ${VG_HOME_DIR}
# install our own updated luarocks
git clone https://github.com/torch/luajit-rocks.git
pushd luajit-rocks
	git checkout 6529891
	cmake . -DWITH_LUAJIT21=ON -DCMAKE_INSTALL_PREFIX=${VG_HOME_DIR}/.local
	make install
popd

echo "export PATH=${VG_HOME_DIR}/.local/bin:${VG_HOME_DIR}/.luarocks/bin:\$PATH" >> ${VG_HOME_DIR}/.bashrc

${VG_HOME_DIR}/.local/bin/luarocks --local install busted 2.0.rc11-0
${VG_HOME_DIR}/.local/bin/luarocks --local install lanes
${VG_HOME_DIR}/.local/bin/luarocks --local install luacheck
${VG_HOME_DIR}/.local/bin/luarocks --local install ansicolors
${VG_HOME_DIR}/.local/bin/luarocks --local install luacov
