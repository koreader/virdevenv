#!/usr/bin/env bash

HOME=/home/ko

cd $HOME || exit

export PATH=${HOME}/local/bin:$PATH

[ ! -d "${HOME}/local/bin" ] && mkdir -p "${HOME}/local/bin"

#install our own updated shellcheck
SHELLCHECK_VERSION="v0.7.2"
SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION?}/shellcheck-${SHELLCHECK_VERSION?}.linux.x86_64.tar.xz"
if ! command -v shellcheck; then
    curl -sSL "${SHELLCHECK_URL}" | tar --exclude 'SHA256SUMS' --strip-components=1 -C "${HOME}/local/bin" -xJf -
    chmod +x "${HOME}/local/bin/shellcheck"
    shellcheck --version
else
    echo -e "${ANSI_GREEN}Using system shellcheck."
fi

# install shfmt
SHFMT_URL="https://github.com/mvdan/sh/releases/download/v3.4.0/shfmt_v3.4.0_linux_amd64"
if [ "$(shfmt --version)" != "v3.4.0" ]; then
    curl -sSL "${SHFMT_URL}" -o "${HOME}/local/bin/shfmt"
    chmod +x "${HOME}/local/bin/shfmt"
else
    echo -e "${ANSI_GREEN}Using system shfmt."
fi
