#!/bin/bash

echo "Building toolchains for kobo..."
git clone https://github.com/koreader/koxtoolchain.git
pushd koxtoolchain
git checkout 052d82036c6a310a950e8ec93065b4a8be9c8f1e

./gen-tc.sh kobo
popd

rm -rf koxtoolchain
