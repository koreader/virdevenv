#!/bin/bash

echo "Building toolchains for kindle..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout e0e19f55d7b5485f6d69394ddd8dcf7c55a28359

    ./gen-tc.sh kindle
    ./gen-tc.sh kindle5
    ./gen-tc.sh kindlepw2
} && popd || exit

rm -rf koxtoolchain
