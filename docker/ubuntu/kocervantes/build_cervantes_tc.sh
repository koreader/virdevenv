#!/bin/bash

echo "Building toolchains for cervantes..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout 576338981f3ba6723801c3056ae2c7ca33915181

    ./gen-tc.sh cervantes
} && popd || exit

rm -rf koxtoolchain
