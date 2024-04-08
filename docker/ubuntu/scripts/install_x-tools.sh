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
unzip -p "$platform.zip" | tar xzv
rm "$platform.zip"
chmod +w -R x-tools/*/
rm -vf x-tools/*/build.log.bz2
hardlink x-tools/
chmod -w -R x-tools/*/

# vim: sw=4
