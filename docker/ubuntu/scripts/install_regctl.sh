#!/bin/bash

# shellcheck source=/dev/null
. "${0%/*}/common.sh"

[ $# -le 1 ]
version="${1:-0.9.2}"

case "${TARGETPLATFORM}" in
    linux/amd64) platform='linux-amd64' ;;
    linux/arm64) platform='linux-arm64' ;;
    *) die "unsupported platform: ${TARGETPLATFORM}" ;;
esac

wget -nv -O /usr/local/bin/regctl "https://github.com/regclient/regclient/releases/download/v${version}/regctl-${platform}"
chmod 755 /usr/local/bin/regctl
regctl version
