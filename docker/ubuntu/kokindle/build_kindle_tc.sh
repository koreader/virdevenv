#!/bin/bash

echo "Building toolchains for kindle..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain
git checkout 47acb959b6169b5d1e546814d1747a8f88484b1b

./gen-tc.sh kindle
./gen-tc.sh kindle5
./gen-tc.sh kindlepw2
popd

rm -rf koxtoolchain
