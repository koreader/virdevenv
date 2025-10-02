#!/bin/bash

# shellcheck source=/dev/null
. "${0%/*}/common.sh"

[ $# -le 1 ]
version="${1:-0.8.22}"

case "${TARGETPLATFORM}" in
    linux/amd64) platform='x86_64-unknown-linux-gnu' ;;
    linux/arm/v7) platform='armv7-unknown-linux-gnueabihf' ;;
    linux/arm64) platform='aarch64-unknown-linux-gnu' ;;
    *) die "unsupported platform: ${TARGETPLATFORM}" ;;
esac

wget -nv -O - "https://github.com/astral-sh/uv/releases/download/${version}/uv-${platform}.tar.gz" | tar -C /usr/local/bin --strip-components=1 -xz
chmod 755 /usr/local/bin/{uv,uvx}
uv --version
