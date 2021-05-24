#!/bin/bash

echo "Building toolchain for PocketBook..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout e0e19f55d7b5485f6d69394ddd8dcf7c55a28359

    ./gen-tc.sh pocketbook
} && popd || exit

rm -rf koxtoolchain
