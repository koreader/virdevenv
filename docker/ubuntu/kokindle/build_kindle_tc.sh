#!/bin/bash

echo "Building toolchains for kindle..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout 052d82036c6a310a950e8ec93065b4a8be9c8f1e

    ./gen-tc.sh kindle || ./gen-tc.sh kindle
    ./gen-tc.sh kindle5 || ./gen-tc.sh kindle5
    ./gen-tc.sh kindlepw2 || ./gen-tc.sh kindlepw2
} && popd || exit

rm -rf koxtoolchain
