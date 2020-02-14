#!/bin/bash

echo "Building toolchain for PocketBook..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    # obviously change this before merging
    git fetch origin pull/22/head
    git checkout FETCH_HEAD

    ./gen-tc.sh pocketbook
} && popd || exit

rm -rf koxtoolchain
