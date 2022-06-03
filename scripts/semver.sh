#!/usr/bin/bash

function semver() {
    local DESCRIBE=`git -C $1 describe --tags --always`
    if [[ "${DESCRIBE}" =~ ^[v] ]]; then
        DESCRIBE="${DESCRIBE:1}"
    fi

    # increment the build number (ie 115 to 116)
    local VERSION=`echo $DESCRIBE | awk '{split($0,a,"-"); print a[1]}'`
    local BUILD=`echo $DESCRIBE | awk '{split($0,a,"-"); print a[2]}'`
    local PATCH=`echo $DESCRIBE | awk '{split($0,a,"-"); print a[3]}'`

    if [[ "${DESCRIBE}" =~ ^[A-Fa-f0-9]+$ ]]; then
        VERSION="0.0.0"
        BUILD=`git rev-list HEAD --count`
        PATCH=${DESCRIBE}
    fi

    if [ "${BUILD}" = "" ]; then
        BUILD='0'
        echo ${VERSION}
        return
    fi

    if [ "${BUILD}" = "" ]; then
        PATCH=$DESCRIBE
    fi

    if [ ! -z "$2" ]; then
        echo ${2}+build.0-og.${VERSION}.build.${BUILD}.${PATCH}
        return
    fi

    echo ${VERSION}+build.${BUILD}.${PATCH}
}