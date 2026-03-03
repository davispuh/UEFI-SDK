#!/usr/bin/sh

set -e

cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=./uefi-toolchain.cmake -DCMAKE_BUILD_TYPE=Release -S . -B ./build
cmake --build ./build
cmake --install ./build --prefix ./installed
