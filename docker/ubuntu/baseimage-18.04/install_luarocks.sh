#!/usr/bin/env bash

HOME=/home/ko

cd $HOME || exit

git clone https://github.com/torch/luajit-rocks.git
pushd luajit-rocks && {
    git checkout 2c7496b905f6f972673effda4884766433b7583b
    cmake . -DWITH_LUAJIT21=ON -DCMAKE_INSTALL_PREFIX=${HOME}/local
    make install
} && popd || exit
rm -rf luajit-rocks

mkdir ${HOME}/.luarocks
cp ${HOME}/local/etc/luarocks/config.lua ${HOME}/.luarocks/config.lua

export PATH=$HOME/local/bin:$PATH

echo "wrap_bin_scripts = false" >>${HOME}/.luarocks/config.lua
luarocks --local install luafilesystem
luarocks --local install ansicolors
luarocks --local install busted 2.0.0-1
luarocks --local install luacov
# luasec doesn't automatically detect 64-bit libs
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu
luarocks --local install luacov-coveralls --server=http://rocks.moonscript.org/dev
luarocks --local install luacheck
luarocks --local install lanes # for parallel luacheck
luarocks --local install ldoc
