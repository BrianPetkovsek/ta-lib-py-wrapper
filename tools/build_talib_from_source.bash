#!/bin/bash
set -e

if [[ -z $2 ]]; then
  echo "Usage: $0 build_dir install_prefix"
  exit 1
fi

BUILD_DIR=$1
INSTALL_PREFIX=$2


TA_LIB_TGZ="ta-lib-rt-0.7.0alpha-src-for-wrapper.tar.gz"
TA_LIB_URL="https://github.com/trufanov-nok/ta-lib-rt/releases/download/v0.7.0alpha/$TA_LIB_TGZ"

if [[ -d $BUILD_DIR/lib ]]; then
  echo "Already built"
  exit 0
fi
mkdir -p $BUILD_DIR/tmp
wget -O "$BUILD_DIR/tmp/$TA_LIB_TGZ" $TA_LIB_URL
pushd $BUILD_DIR/tmp
tar -zxvf $TA_LIB_TGZ
popd
mkdir -p $BUILD_DIR/tmp/ta-lib-rt/build
pushd $BUILD_DIR/tmp/ta-lib-rt/build
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
make install
popd
