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

# Build deps
pushd out

mkdir -p deps
pushd deps
if [[ -z ${DEBUG} ]]; then
    cmake /opt/src/bindbc-imgui/deps
    cmake --build . --config Release
else
    cmake /opt/src/bindbc-imgui/deps -DCMAKE_BUILD_TYPE=Debug 
    cmake --build . --config Debug
fi

popd

popd

# Build inochi-creator
pushd src
pushd inochi-creator
if [[ -z ${DEBUG} ]]; then
    DFLAGS='-link-defaultlib-shared=true' dub build
else
    DFLAGS='-link-defaultlib-shared=true -g --d-debug' dub build
fi
popd
popd

# Install
rsync -r /opt/src/inochi-creator/out/ /opt/out/inochi/
find /opt/out/deps/ -iname "*.so*" -exec cp {} /opt/out/inochi/ \;
