#!/bin/bash

echo "Building toolchains for reMarkable..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain && {
    git checkout eb06c91c548bfac25d921da9dfd1160151e01077

    ./gen-tc.sh remarkable
} && popd || exit

rm -rf koxtoolchain
