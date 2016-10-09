#!/bin/bash

HOME=/home/ko

. /etc/bash_completion

export PATH=$HOME/local/bin:$PATH
if [ -f ${HOME}/local/bin/luarocks ]; then
    # add local rocks to $PATH
    eval $(luarocks path --bin)
fi

XTOOLS=${HOME}/x-tools
export PATH=${XTOOLS}/arm-kobo-linux-gnueabihf/bin:${XTOOLS}/arm-kindlepw2-linux-gnueabi/bin:${XTOOLS}/arm-kindle5-linux-gnueabi/bin:${XTOOLS}/arm-kindle-linux-gnueabi/bin:$PATH
