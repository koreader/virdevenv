#!/bin/bash

HOME=/home/ko

. /etc/bash_completion

export PATH=$HOME/local/bin:$PATH
if [ -f ${HOME}/local/bin/luarocks ]; then
    # add local rocks to $PATH
    eval "$(luarocks path --bin)"
fi

XTOOLS=${HOME}/x-tools

for tc in "${XTOOLS}"/*/bin; do
    export PATH=$tc:$PATH;
done

alias ls='ls --color=auto'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

mkcd () {
    mkdir -p "$*"
    cd "$*" || exit
}
