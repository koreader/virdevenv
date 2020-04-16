#!/bin/bash

echo "Building toolchains for bookeen..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout 78aceb1bd470ff5b1acc016613ce12ac33f286c6

    ./gen-tc.sh bookeen
} && popd || exit

rm -rf koxtoolchain
