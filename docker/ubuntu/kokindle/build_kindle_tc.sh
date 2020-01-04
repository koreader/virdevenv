#!/bin/bash

echo "Building toolchains for kindle..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout 576338981f3ba6723801c3056ae2c7ca33915181

    ./gen-tc.sh kindle || ./gen-tc.sh kindle
    ./gen-tc.sh kindle5 || ./gen-tc.sh kindle5
    ./gen-tc.sh kindlepw2 || ./gen-tc.sh kindlepw2
} && popd || exit

rm -rf koxtoolchain
