#!/bin/bash

echo "Building toolchains for cervantes..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout bcf9e4584cacfc400918b6f6cc20a7dda011d6de

    ./gen-tc.sh cervantes
} && popd || exit

rm -rf koxtoolchain
