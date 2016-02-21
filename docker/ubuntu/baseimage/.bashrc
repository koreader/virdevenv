#!/bin/bash

HOME=/home/ko

export PATH=$HOME/local/bin:$PATH
if [ -f ${HOME}/local/bin/luarocks ]; then
    # add local rocks to $PATH
    eval $(luarocks path --bin)
fi
