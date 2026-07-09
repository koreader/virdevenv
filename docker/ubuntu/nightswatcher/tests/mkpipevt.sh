#!/bin/bash
# shellcheck disable=SC2034

set -eo pipefail

# shellcheck disable=SC2016
declare -r AWK_TAR_BLOCKLIST='
BEGIN {
    FS = "[: ]+"
    ORS = ""
    TAR_BS = 512
    prev_offset = 0
}
{
    if ($2)
        print ($2 - prev_offset) * TAR_BS ","
    prev_offset = $2
}
END {
    print 0
}
'

cd "${0%/*}"

build_jobs=(
    android
    android_aarch64
    android_x86
    kindlepw2
    linux_aarch64
    linux_armhf
    linux_x86_64
    remarkable
    remarkable_aarch64
)

build_android_artifacts='
koreader/koreader-android-arm-@V@.apk
koreader/koreader-android-fdroid-latest
'
build_android_aarch64_artifacts="${build_android_artifacts//-arm-/-arm64-}"
build_android_x86_artifacts="${build_android_artifacts//-arm-/-x86-}"

build_kindlepw2_artifacts='
koreader/koreader-kindlepw2-@V@.tar.xz
koreader/koreader-kindlepw2-@V@.targz
koreader/koreader-kindlepw2-@V@.zip
'
build_kindlepw2_kodir='koreader'
build_kindlepw2_manifest='koreader/ota/package.index'

build_linux_x86_64_artifacts='
koreader/koreader-@V@-x86_64.AppImage
koreader/koreader_@DV@_amd64.deb
koreader/koreader-linux-x86_64-@V@.tar.xz
'
build_linux_aarch64_artifacts='
koreader/koreader-@V@-aarch64.AppImage
koreader/koreader_@DV@_arm64.deb
koreader/koreader-linux-aarch64-@V@.tar.xz
'
build_linux_armhf_artifacts='
koreader/koreader-@V@-armhf.AppImage
koreader/koreader_@DV@_armhf.deb
koreader/koreader-linux-armv7l-@V@.tar.xz
'

build_remarkable_artifacts='
koreader/koreader-remarkable-@V@.tar.xz
koreader/koreader-remarkable-@V@.targz
koreader/koreader-remarkable-@V@.zip
'
build_remarkable_kodir='koreader'
build_remarkable_manifest='koreader/ota/package.index'
build_remarkable_aarch64_artifacts="${build_remarkable_artifacts//remarkable/remarkable-aarch64}"
build_remarkable_aarch64_kodir="${build_remarkable_kodir}"
build_remarkable_aarch64_manifest="${build_remarkable_manifest}"

mkparents() {
    if [[ "$1" = */* ]]; then
        mkdir -p "${1%/*}"
    fi
}

genpipe() {
    local version intver debver
    version="$1"
    # v2024.03.1                         → 2024031000
    # v2025.10                           → 2025100000
    # v2025.10-29-g55bf6c9c5_2025-11-20  → 2025100029
    # v2025.10-167-g0c6d217e3_2026-03-05 → 2025100167
    intver="$(sed -E 's/^v//; s/-g.*//; s/\.//g; s/^[0-9]+$/&-000/; s/^([0-9]{6})-/\10-/; s/-(.{1})$/00\1/; s/-(.{2})$/0\1/; s/-//; ' <<<"${version}")"
    # v2024.03.1                         → 2024.03.1-1
    # v2025.10                           → 2025.10-1
    # v2025.10-29-g55bf6c9c5_2025-11-20  → 2025.10-29-g55bf6c9c5-1
    # v2025.10-167-g0c6d217e3_2026-03-05 → 2025.10-167-g0c6d217e3-1
    debver="$(sed -E 's/^v//; s/_.*//; s/$/-1/' <<<"${version}")"
    printf '%s\t' "${version}" "${intver}" "${debver}"
    echo
    cat >"${version}.json" <<EOF
{
  "object_kind": "pipeline",
  "object_attributes": {
    "id": ${intver},
    "status": "success"
  },
  "commit": {
    "id": "${version}",
    "message": "version: ${version}\n"
  },
  "builds": [
EOF
    local id
    local n=0
    local comma=,
    local artifacts
    for j in "${build_jobs[@]}"; do
        n=$((n + 1))
        [[ ${n} -lt ${#build_jobs[@]} ]] || comma=''
        id="$(printf '%u%03u' "${intver}" "${n}")"
        artifacts="build_${j}_artifacts"
        artifacts="${!artifacts}"
        artifacts="${artifacts//@V@/${version}}"
        artifacts="${artifacts//@DV@/${debver}}"
        artifacts_zip="${PWD}/${id}.zip"
        (
            tmpdir="$(mktemp -d -t tmp7z.XXXXXXXXXX)"
            trap 'rm -rf "${tmpdir}"' EXIT
            kodir="build_${j}_kodir"
            kodir="${!kodir}"
            manifest="build_${j}_manifest"
            manifest="${!manifest}"
            cd "${tmpdir}"
            # Create fake release contents.
            mkdir -p "release/${kodir}/ffi"
            echo >"release/${kodir}/ffi/posix.lua" 'ffi/posix.lua'
            echo >"release/${kodir}/luajit" luajit
            echo >"release/${kodir}/koreader.sh" "${j}"
            echo >"release/${kodir}/git-rev" "${version}"
            find release -type f \( -name '.*' -prune -o -printf '%P\n' \) | sort >release/.paths
            if [[ -n "${manifest}" ]]; then
                mkparents "release/${manifest}"
                echo "${manifest}" >>release/.paths
                cp release/.paths "release/${manifest}"
            fi
            # Create artifacts.
            mkdir -p artifacts
            for a in ${artifacts}; do
                a="${PWD}/artifacts/${a}"
                mkparents "${a}"
                case "${a}" in
                    *.AppImage | *.apk | *.deb | */koreader-android-fdroid-latest)
                        touch "${a}"
                        ;;
                    *.zip)
                        (cd release && zip "${a}" -q -@ <.paths)
                        ;;
                    *.tar.xz)
                        (
                            tar="${a%.xz}"
                            cd release
                            tar -cf "${tar}" --files-from=.paths
                            tar --block-number --list --file="${tar}" >.tarindex
                            awk "${AWK_TAR_BLOCKLIST}" <.tarindex >.blocklist
                            xz --block-size=32M --block-list="$(cat .blocklist)" --stdout <"${tar}" >"${a}"
                            rm "${tar}"
                        )
                        ;;
                    *.targz)
                        (cd release && tar -cf "${a}" --files-from=.paths --gzip)
                        ;;
                    *)
                        echo "unsupported artifact type: ${a##*/}" 1>&2
                        exit 1
                        ;;
                esac
            done
            # Create final zip of all artifacts.
            rm -f "${artifacts_zip}"
            (cd artifacts && zip "${artifacts_zip}" -q -r .)
        )
        cat >>"${version}.json" <<-EOF
    {
      "id": ${id},
      "name": "build_${j}",
      "status": "success"
    }${comma}
EOF
    done
    echo >>"${version}.json" $'  ]\n}'
    jq <"${version}.json"
}

for v in "$@"; do
    genpipe "${v}"
done
