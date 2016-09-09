#!/usr/bin/env bash

# install necessary development tools for building LDC
yum -y install git wget gcc gcc-c++ patch libconfig libconfig-devel zlib zlib-devel cmake28

# clone LDC repo
cd /tmp
git clone --recursive https://github.com/ldc-developers/ldc.git -b release-0.17.1

# patch D runtime so as not to depend on newer glibc
cd /tmp/ldc/runtime/druntime
mv /tmp/d-runtime-qsort.patch .
patch -p1 < d-runtime-qsort.patch

# build and install LDC
cd /tmp/ldc
mkdir build
cd build
export PATH=/opt/llvm/bin:$PATH
cmake28 ..
make && make install

# build and install rdmd
cd /tmp
wget -q https://raw.githubusercontent.com/D-Programming-Language/tools/2.064/rdmd.d
ldmd2 rdmd.d
cp rdmd /usr/local/bin

# remove packages that are no more necessary
# (remaining ones: llvm gcc git zlib libconfig zlib-devel)
yum -y remove gcc-c++ patch libconfig-devel wget
yum clean all
rm -rf /tmp/*
