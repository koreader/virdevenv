#!/bin/bash

echo "Building toolchains for reMarkable..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout ca4481e00fb8b6081c578c0241185444c7ca5ff3

    ./gen-tc.sh remarkable
} && popd || exit

rm -rf koxtoolchain
