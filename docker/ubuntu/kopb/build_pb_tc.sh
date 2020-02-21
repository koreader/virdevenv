#!/bin/bash

echo "Building toolchain for PocketBook..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout 711acc41e2582c63873c4f1a29696cfb6f1a247a

    ./gen-tc.sh pocketbook
} && popd || exit

rm -rf koxtoolchain
