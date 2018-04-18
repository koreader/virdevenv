#!/bin/bash

echo "Building toolchains for kindle..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain
git checkout 2a79651be67b273beb6329bdd249f9e1fdf55e7b

./gen-tc.sh kindle || ./gen-tc.sh kindle
./gen-tc.sh kindle5 || ./gen-tc.sh kindle5
./gen-tc.sh kindlepw2 || ./gen-tc.sh kindlepw2
popd

rm -rf koxtoolchain
