#!/bin/bash
# shellcheck disable=SC2034

set -eo pipefail

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
koreader/koreader-kindlepw2-@V@.targz
koreader/koreader-kindlepw2-@V@.zip
'

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
koreader/koreader-remarkable-@V@.targz
koreader/koreader-remarkable-@V@.zip
'
build_remarkable_aarch64_artifacts='
koreader/koreader-remarkable-aarch64-@V@.targz
koreader/koreader-remarkable-aarch64-@V@.zip
'

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
    {
        cat <<EOF
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
            # shellcheck disable=SC2086
            ./mkartifacts.py "${id}.zip" ${artifacts} 1>&2
            cat <<-EOF
{
  "id": ${id},
  "name": "build_${j}",
  "status": "success"
}${comma}
EOF
        done
        echo ']}'
    } | jq | tee "${version}.json" | jq --color-output
}

for v in "$@"; do
    genpipe "${v}"
done
