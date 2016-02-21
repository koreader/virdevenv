HOME=/home/ko

cd $HOME

git clone https://github.com/torch/luajit-rocks.git
cd luajit-rocks
	git checkout 6529891
	cmake . -DWITH_LUAJIT21=ON -DCMAKE_INSTALL_PREFIX=${HOME}/local
	make install
cd -
rm -rf luajit-rocks

mkdir ${HOME}/.luarocks
cp ${HOME}/local/etc/luarocks/config.lua ${HOME}/.luarocks/config.lua

export PATH=$HOME/local/bin:$PATH

echo "wrap_bin_scripts = false" >> ${HOME}/.luarocks/config.lua
luarocks --local install luafilesystem
luarocks --local install ansicolors
luarocks --local install busted 2.0.rc11-0
luarocks --local install luacov
# luasec doesn't automatically detect 64-bit libs
luarocks --local install luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu
luarocks --local install luacov-coveralls --server=http://rocks.moonscript.org/dev
luarocks --local install luacheck
luarocks --local install lanes  # for parallel luacheck
luarocks --local install ldoc
