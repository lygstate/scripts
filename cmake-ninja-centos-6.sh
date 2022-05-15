#!/bin/bash
#
# This script setups cmake and ninja

pushd /tmp

if [[ ! -f "cmake-3.23.1-linux-x86_64.sh" ]]; then
    wget --no-check-certificate https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-linux-x86_64.sh -O cmake-3.23.1-linux-x86_64.sh
fi
chmod +x cmake-3.23.1-linux-x86_64.sh
./cmake-3.23.1-linux-x86_64.sh --skip-license --prefix=/usr

if [[ ! -f "ninja.tar.gz" ]]; then
    wget --no-check-certificate https://github.com/ninja-build/ninja/archive/refs/tags/v1.11.0.tar.gz -O ninja.tar.gz
fi
rm -rf ninja-1.11.0
tar xf ninja.tar.gz
mkdir ninja-1.11.0/build
pushd ninja-1.11.0/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc) install
popd
