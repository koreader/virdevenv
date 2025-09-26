#!/bin/bash

set -eo pipefail

die() {
    echo "$@" 1>&2
    exit 1
}

if [ -z "${TARGETPLATFORM}" ]; then
    platform="$(uname -s -m | tr 'A-Z ' 'a-z/')"
    case "${platform}" in
        linux/arm64) TARGETPLATFORM=linux/arm64 ;;
        linux/armv7l) TARGETPLATFORM=linux/arm/v7 ;;
        linux/x86_64) TARGETPLATFORM=linux/amd64 ;;
        *) die "unsupported platform: ${platform}" ;;
    esac
    platform=''
fi
