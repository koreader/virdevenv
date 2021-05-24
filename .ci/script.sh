#!/usr/bin/env bash

CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${CI_DIR}/common.sh"

export PATH=$PWD/bin:$PATH

#install our own updated shellcheck
SC_VERSION="0.7.2"
SC_VERSION_FULL="v${SC_VERSION}"
SHELLCHECK_URL="https://github.com/koalaman/shellcheck/releases/download/${SC_VERSION_FULL}/shellcheck-${SC_VERSION_FULL}.linux.x86_64.tar.xz"
if [[ "$(shellcheck --version)" != *"$SC_VERSION"* ]]; then
    wget "${SHELLCHECK_URL}"
    tar --xz -xvf shellcheck-"${SC_VERSION_FULL}".linux.x86_64.tar.xz
    cp shellcheck-"${SC_VERSION_FULL}"/shellcheck "${HOME}/bin/"
else
    echo -e "${ANSI_GREEN}Using cached shellcheck."
fi
shellcheck --version

# install shfmt
SHFMT_URL="https://github.com/mvdan/sh/releases/download/v2.5.1/shfmt_v2.5.1_linux_amd64"
if [ "$(shfmt --version)" != "v2.5.1" ]; then
    curl -sSL "${SHFMT_URL}" -o "${HOME}/bin/shfmt"
    chmod +x "${HOME}/bin/shfmt"
else
    echo -e "${ANSI_GREEN}Using cached shfmt."
fi

# shellcheck disable=2016
mapfile -t shellscript_locations < <({ git grep -lE '^#!(/usr)?/bin/(env )?(bash|sh)' && git submodule --quiet foreach '[ "$path" = "thirdparty/kpvcrlib/crengine" ] && git grep -lE "^#!(/usr)?/bin/(env )?(bash|sh)" | grep .ci | sed "s|^|$path/|" || git grep -lE "^#!(/usr)?/bin/(env )?(bash|sh)" | sed "s|^|$path/|"' && git ls-files ./*.sh; } | sort | uniq)

SHELLSCRIPT_ERROR=0

for shellscript in "${shellscript_locations[@]}"; do
    echo -e "${ANSI_GREEN}Running shellcheck on ${shellscript}"
    shellcheck "${shellscript}" || SHELLSCRIPT_ERROR=1
    echo -e "${ANSI_GREEN}Running shfmt on ${shellscript}"
    if ! shfmt -i 4 "${shellscript}" >/dev/null 2>&1; then
        echo -e "${ANSI_RED}Warning: ${shellscript} contains the following problem:"
        shfmt -i 4 "${shellscript}" || SHELLSCRIPT_ERROR=1
        continue
    fi
    if [ "$(cat "${shellscript}")" != "$(shfmt -i 4 "${shellscript}")" ]; then
        echo -e "${ANSI_RED}Warning: ${shellscript} does not abide by coding style, diff for expected style:"
        shfmt -i 4 "${shellscript}" | diff "${shellscript}" - || SHELLSCRIPT_ERROR=1
    fi
done

exit "${SHELLSCRIPT_ERROR}"
