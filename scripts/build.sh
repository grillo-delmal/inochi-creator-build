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
rsync -r /opt/orig/dportals/ /opt/src/dportals/

# Add dlang deps
dub add-local /opt/src/inochi2d/        "$(semver /opt/src/inochi2d/)"
dub add-local /opt/src/psd-d/           "$(semver /opt/src/psd-d/)"
dub add-local /opt/src/gitver/          "$(semver /opt/src/gitver/)"
dub add-local /opt/src/bindbc-imgui/    "$(semver /opt/src/bindbc-imgui/)"
dub add-local /opt/src/facetrack-d/     "$(semver /opt/src/facetrack-d/)"
dub add-local /opt/src/fghj/            "$(semver /opt/src/fghj/)"
dub add-local /opt/src/inmath/          "$(semver /opt/src/inmath/)"
dub add-local /opt/src/vmc-d/           "$(semver /opt/src/vmc-d/)"
dub add-local /opt/src/i18n/            "$(semver /opt/src/i18n/)"
dub add-local /opt/src/dportals/        "$(semver /opt/src/dportals/)"

# Build bindbc-imgui deps
pushd src
pushd bindbc-imgui
mkdir -p deps/build_linux_x64_cimguiStatic

ARCH=$(uname -m)
if [ "${ARCH}" == 'x86_64' ]; then
    if [[ -z ${DEBUG} ]]; then
        cmake -DSTATIC_CIMGUI= -S deps -B deps/build_linux_x64_cimguiStatic
        cmake --build deps/build_linux_x64_cimguiStatic --config Release
    else
        cmake -DCMAKE_BUILD_TYPE=Debug -DSTATIC_CIMGUI= -S deps -B deps/build_linux_x64_cimguiStatic
        cmake --build deps/build_linux_x64_cimguiStatic --config Debug
    fi
elif [ "${ARCH}" == 'aarch64' ]; then
    if [[ -z ${DEBUG} ]]; then
        cmake -DSTATIC_CIMGUI= -S deps -B deps/build_linux_aarch64_cimguiStatic
        cmake --build deps/build_linux_aarch64_cimguiStatic --config Release
    else
        cmake -DCMAKE_BUILD_TYPE=Debug -DSTATIC_CIMGUI= -S deps -B deps/build_linux_aarch64_cimguiStatic
        cmake --build deps/build_linux_aarch64_cimguiStatic --config Debug
    fi
fi

popd
popd

# Build inochi-creator
# Build inochi-session
pushd src
pushd inochi-creator
if [[ ! -z ${DEBUG} ]]; then
    export DFLAGS='-g --d-debug'
fi
export DC='/usr/bin/ldc2'
echo "Download time" > /opt/out/stats 
{ time dub describe --config=barebones 2>&1 > /opt/out/describe ; }  2>> /opt/out/stats
echo "" >> /opt/out/stats 
echo "Build time" >> /opt/out/stats 
{ time dub build --config=barebones --override-config=facetrack-d/web-adaptors 2>&1 ; } 2>> /opt/out/stats
popd
popd

# Install
rsync -r /opt/src/inochi-creator/out/ /opt/out/inochi/
echo "" >> /opt/out/stats 
echo "Result files" >> /opt/out/stats 
echo "" >> /opt/out/stats 
du -sh /opt/out/inochi/* >> /opt/out/stats
dub list > /opt/out/version_dump