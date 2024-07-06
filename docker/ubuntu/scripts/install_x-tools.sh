#!/bin/bash

set -eo pipefail

if [[ $# -ne 2 ]]; then
    echo "USAGE: $0 PLATFORM VERSION" 1>&2
    exit 1
fi

platform="$1"
version="$2"
shift 2

echo "installing x-tools: $platform $version"

wget --progress=dot:giga "https://github.com/koreader/koxtoolchain/releases/download/$version/$platform.zip"
unzip -p "$platform.zip" | sudo tar xzv -C /usr/local
rm "$platform.zip"
cd /usr/local
sudo chmod +w -R x-tools/*/
sudo rm -vf x-tools/*/build.log.bz2
sudo hardlink x-tools/
sudo chmod -w,og=rX -R x-tools/*/

# vim: sw=4
