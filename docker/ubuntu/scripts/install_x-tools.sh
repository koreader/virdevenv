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
version="${2:-2026.08}"
format='tar.gz'

if dpkg --compare-versions "${version}" ge '2026.08'; then
    format='tar.zst'
fi

echo "installing x-tools: ${target} ${version} [${format}]"

wget -nv "https://github.com/koreader/koxtoolchain/releases/download/${version}/${target}.${format}"
tar xav --no-same-owner -C /opt -f "${target}.${format}"
rm "${target}.${format}"
cd /opt || exit
chmod +w,og=rX -R x-tools/*/
rm -vf x-tools/*/build.log.bz2
hardlink --ignore-time x-tools/
mkdir -p x-tools/bin
for exe in x-tools/*/bin/*; do
    ln --force --symbolic --relative "${exe}" x-tools/bin
done

# vim: sw=4
