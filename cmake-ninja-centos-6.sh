#!/bin/bash
#
# This script setups cmake and ninja

pushd /tmp

wget -q https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-linux-x86_64.sh -O cmake-3.23.1-linux-x86_64.sh
chmod +x cmake-3.23.1-linux-x86_64.sh
./cmake-3.23.1-linux-x86_64.sh --skip-license --prefix=/usr

wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.11.0.tar.gz -O ninja.tar.gz
rm -rf ninja
tar xz ninja.tar.gz
mkdir ninja/build
pushd ninja/build
cmake ..
make -j$(nproc) install
popd
