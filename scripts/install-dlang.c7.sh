#!/usr/bin/bash

set -e

cd ~

mkdir -p ~/dlang && curl -L https://dlang.org/install.sh -o ~/dlang/install.sh
bash ~/dlang/install.sh ldc-1.24.0
source ~/dlang/ldc-1.24.0/activate

curl -L https://github.com/ldc-developers/ldc/releases/download/v1.29.0/ldc-1.29.0-src.tar.gz -o ldc-1.29.0-src.tar.gz
tar -xzf ldc-1.29.0-src.tar.gz
pushd ldc-1.29.0-src

mkdir build
pushd build

scl enable llvm-toolset-7.0 'cmake -S ..'
scl enable llvm-toolset-7.0 'make'
scl enable llvm-toolset-7.0 'make install'

deactivate
popd
popd

curl -L https://github.com/dlang/dub/releases/download/v1.23.0/dub-v1.23.0-linux-x86_64.tar.gz -o dub.tar.gz
tar -xzf dub.tar.gz
cp dub /usr/bin