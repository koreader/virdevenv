#!/bin/bash

echo "Building toolchains for kobo..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain
git checkout 2a79651be67b273beb6329bdd249f9e1fdf55e7b

./gen-tc.sh kobo
popd

rm -rf koxtoolchain
