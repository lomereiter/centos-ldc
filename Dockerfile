FROM centos:6

MAINTAINER "Artem Tarasov" <lomereiter@gmail.com>
# stripped down version of https://github.com/st4ll1/centos6_coati

WORKDIR /opt

RUN yum -y update && yum -y install wget && \
yum -y install centos-release-scl epel-release && \
yum -y update && \
yum -y install devtoolset-4-gcc devtoolset-4-gcc-c++ devtoolset-4-binutils \
wget tar bzip2 cmake3.x86_64 xz git19 python27-python.x86_64 &&\
yum clean all

## Install llvm
ARG LLVM_VERSION=3.8.0
RUN mkdir -p /llvm && cd /llvm && \
wget -q http://llvm.org/releases/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz && \
tar xvf llvm-${LLVM_VERSION}.src.tar.xz && \
cd llvm-${LLVM_VERSION}.src && \
cd tools && \
wget -q http://llvm.org/releases/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.xz && \
tar xvf cfe-${LLVM_VERSION}.src.tar.xz && \
. /opt/rh/python27/enable && \
. /opt/rh/devtoolset-4/enable && \
python --version && \
cd /llvm/llvm-${LLVM_VERSION}.src && mkdir -p build && cd build && \
ln -s /usr/bin/cmake3 /usr/local/bin/cmake && \
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/llvm/ \
-DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_INCLUDE_TESTS="OFF" && \
make install && rm -Rf /llvm

## set env
ENV CXX=/opt/llvm/bin/clang++ \
CC=/opt/llvm/bin/clang \
LLVM_DIR=/opt/llvm

# Make sure the above SCLs are already enabled
ENTRYPOINT ["/usr/bin/scl", "enable", "python27", "devtoolset-4", "git19", "--"]
CMD ["/usr/bin/scl", "enable", "python27", "devtoolset-4", "git19", "--", "/bin/bash"]

RUN GCC_VERSION=$(/opt/rh/devtoolset-4/root/usr/bin/g++ -dumpversion) && \
mkdir -p /usr/include/c++/ && mkdir -p /usr/lib/gcc/x86_64-redhat-linux/ && \
ln -s /opt/rh/devtoolset-4/root/usr/include/c++/${GCC_VERSION} /usr/include/c++/${GCC_VERSION} && \
ln -s /opt/rh/devtoolset-4/root/usr/lib/gcc/x86_64-redhat-linux/${GCC_VERSION} \
/usr/lib/gcc/x86_64-redhat-linux/${GCC_VERSION}

ADD d-runtime-qsort.patch /tmp/d-runtime-qsort.patch
RUN chmod 644 /tmp/d-runtime-qsort.patch

ADD install-software.sh /tmp/install-software.sh
RUN chmod 755 /tmp/install-software.sh
RUN /tmp/install-software.sh
