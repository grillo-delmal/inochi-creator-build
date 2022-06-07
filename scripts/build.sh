#!/usr/bin/bash

set -e

source /opt/build/semver.sh

# Clean out folder
find /opt/out/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} +

cd /opt
mkdir src

rsync -r /opt/orig/inochi-creator/ /opt/src/inochi-creator/

rsync -r /opt/orig/inochi2d/ /opt/src/inochi2d/
rsync -r /opt/orig/bindbc-imgui/ /opt/src/bindbc-imgui/
rsync -r /opt/orig/psd-d/ /opt/src/psd-d/
rsync -r /opt/orig/gitver/ /opt/src/gitver/
rsync -r /opt/orig/facetrack-d/ /opt/src/facetrack-d/
rsync -r /opt/orig/fghj/ /opt/src/fghj/
rsync -r /opt/orig/inmath/ /opt/src/inmath/
rsync -r /opt/orig/vmc-d/ /opt/src/vmc-d/
rsync -r /opt/orig/i18n/ /opt/src/i18n/

mkdir -p /opt/out/patch
# Get static build patch from origin/playmer/cimguiUpdate
BASE_HASH=$(git -C /opt/src/inochi-creator/ rev-parse HEAD)
PATCH_HASH=3ffe4e1d58f913fc26248dbff716c3833e2520ee
git -C /opt/src/inochi-creator/ diff ...${PATCH_HASH:0:7} \
    'source/creator/core/package.d' \
    > /opt/out/patch/inochi-creator-${BASE_HASH:0:7}-${PATCH_HASH:0:7}.patch
git -C /opt/src/inochi-creator/ apply /opt/out/patch/inochi-creator-${BASE_HASH:0:7}-${PATCH_HASH:0:7}.patch

# Get static build patch from origin/playmer/cimguiUpdate
BASE_HASH=$(git -C /opt/src/bindbc-imgui/ rev-parse HEAD)
PATCH_HASH=244defdff2415205d7f33af0b119ac52fc926ef3
git -C /opt/src/bindbc-imgui diff ...${PATCH_HASH:0:7} \
    'dub.sdl' \
    'deps/CMakeLists.txt' \
    > /opt/out/patch/bindbc-imgui-${BASE_HASH:0:7}-${PATCH_HASH:0:7}.patch
git -C /opt/src/bindbc-imgui apply /opt/out/patch/bindbc-imgui-${BASE_HASH:0:7}-${PATCH_HASH:0:7}.patch

# Patch to silence "function 'xxx' without 'this' cannot be 'const'" error messages
git -C /opt/src/bindbc-imgui apply /opt/build/bindbc-imgui-consts.patch

# Add dlang deps
dub add-local /opt/src/inochi2d/        "$(semver /opt/src/inochi2d/ 0.7.2)"
dub add-local /opt/src/psd-d/           "$(semver /opt/src/psd-d/)"
dub add-local /opt/src/gitver/          "$(semver /opt/src/gitver/)"
dub add-local /opt/src/bindbc-imgui/    "$(semver /opt/src/bindbc-imgui/ 1.0.1)"
dub add-local /opt/src/facetrack-d/     "$(semver /opt/src/facetrack-d/)"
dub add-local /opt/src/fghj/            "$(semver /opt/src/fghj/)"
dub add-local /opt/src/inmath/          "$(semver /opt/src/inmath/)"
dub add-local /opt/src/vmc-d/           "$(semver /opt/src/vmc-d/)"
dub add-local /opt/src/i18n/            "$(semver /opt/src/i18n/)"

# Build bindbc-imgui deps
pushd src
pushd bindbc-imgui
pushd deps
mkdir build_linux_x64_cimguiStatic
pushd build_linux_x64_cimguiStatic

if [[ -z ${DEBUG} ]]; then
    cmake .. -DSTATIC_CIMGUI=
    cmake --build . --config Release
else
    cmake .. -DSTATIC_CIMGUI= -DCMAKE_BUILD_TYPE=Debug 
    cmake --build . --config Debug
fi

popd
popd
popd
popd

# Build inochi-creator
pushd src
pushd inochi-creator
if [[ -z ${DEBUG} ]]; then
    if [[ ! -z ${SHARED_DLANG} ]]; then
        export DFLAGS='-link-defaultlib-shared=true -g --d-debug'
    fi
else
    if [[ ! -z ${SHARED_DLANG} ]]; then
        export DFLAGS='-link-defaultlib-shared=true -g --d-debug'
    else
        export DFLAGS='-g --d-debug'
    fi
fi
dub build
popd
popd

# Install
rsync -r /opt/src/inochi-creator/out/ /opt/out/inochi/

dub list > /opt/out/version_dump