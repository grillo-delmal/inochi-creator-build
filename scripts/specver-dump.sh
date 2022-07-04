#!/usr/bin/bash

set -e

source ./scripts/semver.sh
source ./scripts/gitver.sh

SEMVER=$(semver ./src/inochi-creator)
COMMIT=$(git -C ./src/inochi-creator rev-parse HEAD)
GITVER=$(git_version ./src/inochi-creator)
GITDIST=$(git_build ./src/inochi-creator)

echo "%define inochi_creator_ver ${GITVER}"
echo "%define inochi_creator_semver ${SEMVER}"
echo "%define inochi_creator_dist ${GITDIST}"
echo "%define inochi_creator_commit ${COMMIT}"
echo "%define inochi_creator_short ${COMMIT:0:7}"
echo ""

echo '# Project maintained deps'
cat build_out/version_dump | tail -n +2 | grep '/opt/src/' | sort | while read line
do
    readarray -d ':' -t ARR_A <<< "$line"
    readarray -d ' ' -t ARR_B <<< "${ARR_A[0]}"

    NAME=$(echo "${ARR_B[0]}" | sed 's/-/_/g' | awk '{print tolower($0)}' )
    SEMVER=$(echo "${ARR_B[1]}" | sed 's/\s+$//g')
    GITPATH=$(echo "${ARR_A[1]}" | sed 's/\/opt\//.\//g')
    COMMIT=$(git -C ${GITPATH} rev-parse HEAD)
    GITVER=$(git -C ${GITPATH} describe --tags)

    echo "%define ${NAME}_semver ${SEMVER}"
    echo "%define ${NAME}_commit ${COMMIT}"
    echo "%define ${NAME}_short ${COMMIT:0:7}"
    echo ""
done

echo '# Indirect deps'
cat build_out/version_dump | tail -n +2 | grep '/root/.' | sort | while read line
do
    readarray -d ':' -t ARR_A <<< "$line"
    readarray -d ' ' -t ARR_B <<< "${ARR_A[0]}"

    NAME=$(echo "${ARR_B[0]}" | sed 's/-/_/g' | awk '{print tolower($0)}' )
    SEMVER=$(echo "${ARR_B[1]}" | sed 's/\s+$//g')

    echo "%define ${NAME}_ver ${SEMVER}"

done
echo ""

echo '# cimgui'

COMMIT=$(git -C ./src/bindbc-imgui/deps/cimgui rev-parse HEAD)
echo "%define cimgui_commit ${COMMIT}"
echo "%define cimgui_short ${COMMIT:0:7}"
COMMIT=$(git -C ./src/bindbc-imgui/deps/cimgui/imgui rev-parse HEAD)
echo "%define imgui_commit ${COMMIT}"
echo "%define imgui_short ${COMMIT:0:7}"
