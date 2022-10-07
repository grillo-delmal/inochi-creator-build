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
rsync -r /opt/orig/facetrack-d/ /opt/src/facetrack-d/
rsync -r /opt/orig/fghj/ /opt/src/fghj/
rsync -r /opt/orig/inmath/ /opt/src/inmath/
rsync -r /opt/orig/vmc-d/ /opt/src/vmc-d/
rsync -r /opt/orig/i18n/ /opt/src/i18n/
rsync -r /opt/orig/dportals/ /opt/src/dportals/

pushd patches
for d in */ ; do
    for p in ${d}*.patch; do
        echo "patch /opt/patches/$p"
        git -C /opt/src/${d} apply /opt/patches/$p
    done
done
popd

cat > /opt/src/inochi-creator/source/creator/ver.d <<EOF
module creator.ver;

enum INC_VERSION = "$(semver /opt/src/inochi-creator/)";
EOF

# FIX: Inochi2D version dependent on git
cat > /opt/src/inochi2d/source/inochi2d/ver.d <<EOF
module inochi2d.ver;

enum IN_VERSION = "$(semver /opt/src/inochi2d/)";
EOF

# Add dlang deps
dub add-local /opt/src/inochi2d/        "$(semver /opt/src/inochi2d/)"
dub add-local /opt/src/psd-d/           "$(semver /opt/src/psd-d/)"
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
pushd src
pushd inochi-creator

# Remove branding assets
rm -rf res/Inochi-Creator.iconset/
find res/ui/ -type f -not -name "grid.png" -delete
rm res/icon.png
rm res/Info.plist
rm res/logo.png
rm res/logo_256.png
rm res/inochi-creator.ico
rm res/inochi-creator.rc
rm res/shaders/ada.frag
rm res/shaders/ada.vert

# Replace files
rm source/creator/config.d
cp /opt/files/config.d source/creator/
cp /opt/files/empty.png res/ui/banner.png

if [[ ! -z ${DEBUG} ]]; then
    export DFLAGS='-g --d-debug'
fi
export DC='/usr/bin/ldc2'
echo "Download time" > /opt/out/stats 
{ time \
    dub describe \
        --config=barebones \
        --cache=local \
            2>&1 > /opt/out/describe ; \
    }  2>> /opt/out/stats
echo "" >> /opt/out/stats 
echo "Build time" >> /opt/out/stats 
{ time \
    dub build \
        --config=barebones \
        --cache=local \
            2>&1 ; \
    } 2>> /opt/out/stats
popd
popd

# Install
rsync -r /opt/src/inochi-creator/out/ /opt/out/inochi/
echo "" >> /opt/out/stats 
echo "Result files" >> /opt/out/stats 
echo "" >> /opt/out/stats 
du -sh /opt/out/inochi/* >> /opt/out/stats
dub list > /opt/out/version_dump