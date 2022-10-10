#!/usr/bin/bash

set -e

source /opt/build/semver.sh

# Clean out folder
find /opt/out/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} +

mkdir -p /opt/src

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

cd /opt
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
mkdir -p /var/lib/dub
cat > /var/lib/dub/settings.json <<EOF
{
    "customCachePaths": ["/usr/include/zdub/"]
}
EOF

function setver() {
    mkdir -p /usr/include/zdub/$1-$2/
    mv /opt/src/$1 /usr/include/zdub/$1-$2/
    cd /usr/include/zdub/$1-$2/$1
    setgittag --rm -f -m v$2
}

setver inochi2d      "$(semver /opt/orig/inochi2d/)"
setver psd-d         "$(semver /opt/orig/psd-d/)"
setver bindbc-imgui  "$(semver /opt/orig/bindbc-imgui/)"
setver facetrack-d   "$(semver /opt/orig/facetrack-d/)"
setver fghj          "$(semver /opt/orig/fghj/)"
setver inmath        "$(semver /opt/orig/inmath/)"
setver vmc-d         "$(semver /opt/orig/vmc-d/)"
setver i18n          "$(semver /opt/orig/i18n/)"
setver dportals      "$(semver /opt/orig/dportals/)"

# Build inochi-creator
cd /opt
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
dub list > /opt/out/version_dump_pre
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
dub list > /opt/out/version_dump
popd
popd

# Install
rsync -r /opt/src/inochi-creator/out/ /opt/out/inochi/
echo "" >> /opt/out/stats 
echo "Result files" >> /opt/out/stats 
echo "" >> /opt/out/stats 
du -sh /opt/out/inochi/* >> /opt/out/stats
