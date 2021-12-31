#!/usr/bin/env bash

apt-get install --no-install-recommends luarocks

luarocks install luacov
luarocks install ldoc

luarocks install lanes # for parallel luacheck
luarocks install luacheck

luarocks build https://raw.githubusercontent.com/Olivine-Labs/busted/2e4799e06b865c352baa7f7721e32aedaafd19d6/busted-scm-2.rockspec
