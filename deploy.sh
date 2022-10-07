#!/usr/bin/bash

set -e

podman build -t inochi-creator-build .

mkdir -p $(pwd)/build_out

podman unshare chown $UID:$UID -R $(pwd)/build_out

podman run -ti --rm \
    -v $(pwd)/build_out:/opt/out/:Z \
    -v $(pwd)/.git:/opt/.git/:ro,Z \
    -v $(pwd)/src/inochi2d:/opt/orig/inochi2d/:ro,Z \
    -v $(pwd)/src/inochi-creator:/opt/orig/inochi-creator/:ro,Z \
    -v $(pwd)/src/bindbc-imgui:/opt/orig/bindbc-imgui/:ro,Z \
    -v $(pwd)/src/psd-d:/opt/orig/psd-d/:ro,Z \
    -v $(pwd)/src/gitver:/opt/orig/gitver/:ro,Z \
    -v $(pwd)/src/facetrack-d:/opt/orig/facetrack-d/:ro,Z \
    -v $(pwd)/src/fghj:/opt/orig/fghj/:ro,Z \
    -v $(pwd)/src/inmath:/opt/orig/inmath/:ro,Z \
    -v $(pwd)/src/vmc-d:/opt/orig/vmc-d/:ro,Z \
    -v $(pwd)/src/i18n:/opt/orig/i18n/:ro,Z \
    -v $(pwd)/src/dportals:/opt/orig/dportals/:ro,Z \
    -v $(pwd)/patches:/opt/patches/:ro,Z \
    -v $(pwd)/files:/opt/files/:ro,Z \
    -e DEBUG=${DEBUG} \
    localhost/inochi-creator-build:latest

podman unshare chown 0:0 -R $(pwd)/build_out
