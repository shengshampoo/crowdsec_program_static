
#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# abseil-cpp
cd $WORKSPACE
git clone https://github.com/abseil/abseil-cpp.git
cd abseil-cpp
mkdir build0
cd build0
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=yes -DABSL_BUILD_TESTING=OFF -DABSL_USE_GOOGLETEST_HEAD=ON -DCMAKE_CXX_STANDARD=17 ..
ninja
ninja install
cd ../
mkdir build1
cd ./build1
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=no -DABSL_BUILD_TESTING=OFF -DABSL_USE_GOOGLETEST_HEAD=ON -DCMAKE_CXX_STANDARD=17 ..
ninja
ninja install

# re2 
cd $WORKSPACE
git clone https://github.com/google/re2
cd re2
sed -i '/^LDFLAGS = /s/ = / = -static --static -no-pie -s/' ./Makefile
sed -i '/^prefix=/s/local//' ./Makefile
make
make install

# crowdsec
cd $WORKSPACE
git clone https://github.com/crowdsecurity/crowdsec
cd crowdsec
sed -i '/go-re2/s/wasilibs/shengshampoo/' ./go.mod
sed -i '/go-re2/s/v1.10.0/main/' ./go.mod
go clean -modcache
go mod tidy
CGO_CFLAGS="-D_LARGEFILE64_SOURCE" CGO_LDFLAGS="-static --static -no-pie -s -L/usr/lib" make BUILD_STATIC=1 release

# cs-firewall-bouncer
cd $WORKSPACE
git clone https://github.com/crowdsecurity/cs-firewall-bouncer.git
cd cs-firewall-bouncer
make release

cp /tmp/workspace/crowdsec/crowdsec-*.tgz /work/artifact
cp /tmp/workspace/cs-firewall-bouncer/crowdsec-firewall-bouncer*.tgz /work/artifact
