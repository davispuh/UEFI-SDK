#!/usr/bin/sh

set -e

EXAMPLES_DIR=$(realpath $(dirname "$0"))
BUILD_DIR=./buildExamples

# You can also use -DCMAKE_PREFIX_PATH=../installed/
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$EXAMPLES_DIR/../uefi-toolchain.cmake -DCMAKE_BUILD_TYPE=Release -S "$EXAMPLES_DIR" -B "$BUILD_DIR" -DUefiSdk_DIR="$EXAMPLES_DIR/../installed/lib/cmake/UefiSdk/"
cmake --build "$BUILD_DIR"
