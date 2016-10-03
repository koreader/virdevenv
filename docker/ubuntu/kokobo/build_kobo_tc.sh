#!/bin/bash

echo "Building toolchains for kobo..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain
git checkout 47acb959b6169b5d1e546814d1747a8f88484b1b

./gen-tc.sh kobo
popd

rm -rf koxtoolchain
