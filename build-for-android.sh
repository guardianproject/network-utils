#!/bin/sh
#
# in order to get external/openssl, you need to run this from the base
# of the git repo, i.e. sqlcipher/
#
#   git submodule init
#   git submodule update

# TODO add sha1 checking to all downloads
# TODO download tcptraceroute
# TODO make patch for tcptraceroute configure.ac
# TODO push to guardianproject git

CWD=`pwd`
LIB_ROOT=$CWD/root

# Android NDK setup
NDK_BASE=/usr/local/android-ndk
NDK_PLATFORM_LEVEL=8
NDK_SYSROOT=${NDK_BASE}/platforms/android-${NDK_PLATFORM_LEVEL}/arch-arm
NDK_UNAME=`uname -s | tr '[A-Z]' '[a-z]'`
NDK_TOOLCHAIN=${NDK_BASE}/toolchains/arm-linux-androideabi-4.4.3/prebuilt/${NDK_UNAME}-x86

# to use the real HOST tag, you need the latest libtool files:
# http://stackoverflow.com/questions/4594736/configure-does-not-recognize-androideabi
HOST=arm-linux-androideabi

CC="$NDK_TOOLCHAIN/bin/${HOST}-gcc --sysroot=$NDK_SYSROOT"
RANLIB="$NDK_TOOLCHAIN/bin/${HOST}-ranlib"

CFLAGS="-I${LIB_ROOT}/include"
LDFLAGS="-L${LIB_ROOT}/lib"

#------------------------------------------------------------------------------#
# download

wget http://sourceforge.net/projects/libnet-dev/files/libnet-1.1.5.tar.gz/download
tar xzf libnet-1.1.5.tar.gz

wget http://www.tcpdump.org/release/libpcap-1.1.1.tar.gz
tar xzf libpcap-1.1.1.tar.gz


#------------------------------------------------------------------------------#
# build 

mkdir $LIB_ROOT    

echo "----------------------------------------"
echo "libnet"
cd ${CWD}/libnet-1.1.5
cp ../config.guess ../config.sub .
./configure CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --host=${HOST} --prefix= --enable-shared --enable-static
make
make DESTDIR=$LIB_ROOT prefix= install
$RANLIB ${LIB_ROOT}/lib/libnet.a

echo "----------------------------------------"
echo "libpcap-1.1.1"
cd ${CWD}/libpcap-1.1.1
cp ../config.guess ../config.sub .
ac_cv_linux_vers=2 ./configure CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --host=${HOST} --prefix= --enable-shared --enable-static --with-pcap=linux
make
make DESTDIR=$LIB_ROOT prefix= install
$RANLIB ${LIB_ROOT}/lib/libpcap.a

echo "----------------------------------------"
echo "tcptraceroute-1.5beta7"
cd ${CWD}/tcptraceroute-1.5beta7
cp ../config.guess ../config.sub .
autoreconf
automake --add-missing
export ac_cv_func_malloc_0_nonnull=yes 
./configure CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --host=${HOST} --prefix= --enable-static --with-libnet=${LIB_ROOT} --with-libpcap=${LIB_ROOT}
make
make DESTDIR=$LIB_ROOT prefix= install

