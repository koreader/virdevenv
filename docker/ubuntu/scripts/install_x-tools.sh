#!/bin/bash

# shellcheck source=/dev/null
. "${0%/*}/common.sh"

if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]; then
    echo "USAGE: $0 TARGET [VERSION]" 1>&2
    exit 1
fi

case "${TARGETPLATFORM}" in
    linux/amd64) ;;
    *) die "unsupported platform: ${TARGETPLATFORM}" ;;
esac

target="$1"
version="${2:-2025.05}"

echo "installing x-tools: ${target} ${version}"

wget -nv "https://github.com/koreader/koxtoolchain/releases/download/${version}/${target}.tar.gz"
tar xzv --no-same-owner -C /usr/local -f "${target}.tar.gz"
rm "${target}.tar.gz"
cd /usr/local || exit
chmod +w,og=rX -R x-tools/*/
rm -vf x-tools/*/build.log.bz2
hardlink x-tools/

# vim: sw=4
