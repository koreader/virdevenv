#!/bin/bash

# shellcheck source=/dev/null
. "${0%/*}/common.sh"

[ $# -le 1 ]
version="${1:-2.14.0}"

case "${TARGETPLATFORM}" in
    linux/amd64) platform='linux-x86_64' ;;
    linux/arm64) platform='linux-arm64' ;;
    *) die "unsupported platform: ${TARGETPLATFORM}" ;;
esac

wget -nv -O /usr/local/bin/hadolint "https://github.com/hadolint/hadolint/releases/download/v${version}/hadolint-${platform}"
chmod 755 /usr/local/bin/hadolint
hadolint --version
