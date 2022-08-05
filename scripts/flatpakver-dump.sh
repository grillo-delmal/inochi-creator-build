#!/usr/bin/bash

set -e

source ./scripts/semver.sh
source ./scripts/gitver.sh

# echo '# Project maintained deps'
APPS=""

while read -r line
do
    readarray -d ':' -t ARR_A <<< "$line"
    readarray -d ' ' -t ARR_B <<< "${ARR_A[0]}"

    TRUENAME=${ARR_B[0]}
    NAME=$(echo "${TRUENAME}" | sed 's/-/_/g' | awk '{print tolower($0)}' )
    SEMVER=$(echo "${ARR_B[1]}" | sed 's/\s+$//g')
    GITPATH=$(echo "${ARR_A[1]}" | sed 's/\/opt\//.\//g')
    COMMIT=$(git -C ${GITPATH} rev-parse HEAD)
    GITVER=$(git -C ${GITPATH} describe --tags)

    printf "        dub add-local ./deps/${TRUENAME}/ \\"
    echo "          ${SEMVER};"

    APPS+="      - type: git"
    APPS+="\n"
    APPS+="        url: https://github.com/Inochi2D/${TRUENAME}"
    APPS+="\n"
    APPS+="        commit: ${COMMIT}"
    APPS+="\n"
    APPS+="\n"

done < <(cat build_out/version_dump | tail -n +2 | grep '/opt/src/' | sort)

# echo '# Indirect deps'
while read -r line
do
    readarray -d ':' -t ARR_A <<< "$line"
    readarray -d ' ' -t ARR_B <<< "${ARR_A[0]}"

    TRUENAME=${ARR_B[0]}
    NAME=$(echo "${TRUENAME}" | sed 's/-/_/g' | awk '{print tolower($0)}' )
    SEMVER=$(echo "${ARR_B[1]}" | sed 's/\s+$//g')

    echo "        dub add-local ./deps/${TRUENAME}/ \\"
    echo "          ${SEMVER};"

    APPS+="      - type: git"
    APPS+="\n"
    APPS+="        url: ${TRUENAME}"
    APPS+="\n"
    APPS+="        commit: ${SEMVER}"
    APPS+="\n"
    APPS+="\n"
done < <(cat build_out/version_dump | tail -n +2 | grep '/root/.' | sort)
echo ""

SEMVER=$(semver ./src/inochi-creator)
COMMIT=$(git -C ./src/inochi-creator rev-parse HEAD)
GITVER=$(git_version ./src/inochi-creator)
GITDIST=$(git_build ./src/inochi-creator)


echo "      - type: archive"
echo "        url: https://github.com/Inochi2D/inochi-creator/archive/refs/tags/v${GITVER}.tar.gz"
echo "        sha256: "
echo ""

echo -e "${APPS}"