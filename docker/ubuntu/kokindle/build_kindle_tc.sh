#!/bin/bash

echo "Building toolchains for kindle..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout 1f65f8df7844da7675f76b48793e301db87cc18c

    ./gen-tc.sh kindle || ./gen-tc.sh kindle
    ./gen-tc.sh kindle5 || ./gen-tc.sh kindle5
    ./gen-tc.sh kindlepw2 || ./gen-tc.sh kindlepw2
} && popd || exit

rm -rf koxtoolchain
