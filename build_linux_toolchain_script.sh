HOME_DIR=/home/jaguar
REL_PATH=$HOME_DIR/test_scripts
PROJ_DIR=$REL_PATH/linux_toolchain_build





SOURCES_DIR=$PROJ_DIR/sources
COMMON_DOWNLOADS_DIR=$REL_PATH/sources_tar_git

BUILD_DIR=$PROJ_DIR/build_dir 
BINUTILS_BUILD_DIR=$BUILD_DIR/build-binutils  
GLIBC_BUILD_DIR=$BUILD_DIR/build-glibc
GCC_BUILD_DIR=$BUILD_DIR/build-gcc  
GDB_BUILD_DIR=$BUILD_DIR/build-gdb  







BINUTILS_VER=2_35
GLIBC_VER=2.32
LINUX_VER=v5.6
GCC_VER=10
GDB_VER=2_35



BINUTILS_SRC_DIR=$SOURCES_DIR/binutils-$BINUTILS_VER
GCC_SRC_DIR=$SOURCES_DIR/gcc-$GCC_VER
GLIBC_SRC_DIR=$SOURCES_DIR/glibc-$GLIBC_VER
GDB_SRC_DIR=$SOURCES_DIR/gdb-$GDB_VER
LINUX_SRC_DIR=$SOURCES_DIR/linux-$LINUX_VER


TOOLCHAIN_INSTALL_DIR=$PROJ_DIR/toolchain
#TARGET=aarch64-linux-gnu
TARGET=aarch64-foo-linux-gnu
LINUX_ARCH=arm64
MACHTYPE=""
HOST=""

MPC_VER=1.2.1
ISL_VER=0.22.1
MPFR_VER=4.1.0
GMP_VER=6.2.0
CLOOG_VER=0.18.4

MPC_SRC_DIR=mpc-$MPC_VER
ISL_SRC_DIR=isl-$ISL_VER
MPFR_SRC_DIR=mpfr-$MPFR_VER
GMP_SRC_DIR=gmp-$GMP_VER
CLOOG_SRC_DIR=cloog-$CLOOG_VER

# Prints a formatted header to let the user know what's being done
function header() {
    echo -e "${GRN}====$(for i in $(seq ${#1}); do echo -e "=\c"; done)===="
    echo -e "==  ${1}  =="
    echo -e "====$(for i in $(seq ${#1}); do echo -e "=\c"; done)====${RST}"
}

download_sources()
{
    cd $COMMON_DOWNLOADS_DIR
#    mkdir $MPC_SRC_DIR
#    mkdir $ISL_SRC_DIR
#    mkdir $MPFR_SRC_DIR
#    mkdir $GMP_SRC_DIR
#    mkdir $CLOOG_SRC_DIR

    #for baremetal
    wget -nc -O newlib-$NEWLIB_VER.zip https://github.com/bminor/newlib/archive/master.zip

    git clone --depth=1 git://sourceware.org/git/glibc.git $GLIBC_SRC_DIR -b glibc-$GLIBC_VER
    git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git $LINUX_SRC_DIR -b $LINUX_VER
    git clone --depth=1 git://sourceware.org/git/binutils-gdb.git $BINUTILS_SRC_DIR -b binutils-$BINUTILS_VER
    git clone --depth=1 git://gcc.gnu.org/git/gcc.git $GCC_SRC_DIR -b releases/gcc-$GCC_VER
    #git clone --depth=1 git://sourceware.org/git/binutils-gdb.git $GDB_SRC_DIR -b gdb-$GDB_VER

    #wget -nc https://www.kernel.org/pub/linux/kernel/v3.x/$LINUX_KERNEL_VERSION.tar.xz
    #wget -nc https://ftp.gnu.org/gnu/glibc/$GLIBC_VERSION.tar.xz

    #wget -c https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VER.tar.gz
    #tar xvf mpc-$MPC_VER.tar.gz -C $MPC_SRC_DIR  --strip-components=1

    #wget -c http://isl.gforge.inria.fr/isl-$ISL_VER.tar.xz
    #tar xvf isl-$ISL_VER.tar.xz -C $ISL_SRC_DIR --strip-components=1

    #wget -c https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VER.tar.xz
    #tar xvf mpfr-$MPFR_VER.tar.xz -C $MPFR_SRC_DIR --strip-components=1

    #wget -c https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VER.tar.xz
    #tar xvf gmp-$GMP_VER.tar.xz -C $GMP_SRC_DIR --strip-components=1

    #wget -c http://www.bastoul.net/cloog/pages/download/cloog-$CLOOG_VER.tar.gz
    #tar xvf cloog-$CLOOG_VER.tar.gz -C $CLOOG_SRC_DIR --strip-components=1

}

copy_sources()
{
	mkdir -p $SOURCES_DIR
	echo "copy all sources"
	cp -R $COMMON_DOWNLOADS_DIR/sources/* $SOURCES_DIR/
	mkdir -p $GDB_SRC_DIR
	cp -R $BINUTILS_SRC_DIR/* $GDB_SRC_DIR/
}


prepare_gcc_src()
{
	cd $GCC_SRC_DIR
	./contrib/download_prerequisites
#	ln -s $MPFR_SRC_DIR mpfr
#	ln -s $GMP_SRC_DIR  gmp
#	ln -s $MPC_SRC_DIR mpc
#	ln -s $ISL_SRC_DIR isl
#	ln -s $CLOOG_SRC_DIR cloog
}

prepare_build_dir()
{
#	mkdir -p $COMMON_DOWNLOADS_DIR
	mkdir -p $BUILD_DIR
	mkdir -p $BINUTILS_BUILD_DIR 
	mkdir -p $GLIBC_BUILD_DIR
	mkdir -p $GCC_BUILD_DIR  
	mkdir -p $GDB_BUILD_DIR  
}

prepare_install_dir()
{
	sudo mkdir -p $TOOLCHAIN_INSTALL_DIR
	sudo chown jaguar:jaguar $TOOLCHAIN_INSTALL_DIR
	export PATH=$TOOLCHAIN_INSTALL_DIR/bin:$PATH
	echo $PATH
}

set_environment()
{

	MACHTYPE=$($GCC_SRC_DIR/config.guess)
	echo "--build = $MACHTYPE"
	HOST=$MACHTYPE
	echo "--host = $HOST"
	echo "--target=$TARGET"
	export PATH=$TOOLCHAIN_INSTALL_DIR/bin:$PATH
	echo $PATH
}

# Step 1. Binutils
#=========================
#==  BUILDING BINUTILS  ==
#=========================
#builds and installs the cross-assembler, cross-linker, and other tools.

build_binutils()
{

	header "building binutils"
	BINUTIL_CONFIG="--target=$TARGET --prefix=$TOOLCHAIN_INSTALL_DIR --disable-nls --disable-werror --disable-gdb --disable-multilib"

	cd $BINUTILS_BUILD_DIR
	$BINUTILS_SRC_DIR/configure $BINUTIL_CONFIG
	make -j8  all
	make install
	header "built binutils SUCCESSFULLY"
	ls -ltR $TOOLCHAIN_INSTALL_DIR
}

# Step 2. Linux Kernel Headers
#============================
#==  MAKING LINUX HEADERS  ==
#============================


install_linux_headers()
{
	header "installing Linux headers"
	cd $LINUX_SRC_DIR 
	make ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$TOOLCHAIN_INSTALL_DIR/$TARGET headers_install  
	header "successfully installed Linux headers"
	ls -ltR $TOOLCHAIN_INSTALL_DIR/$TARGET
}



# Step 3. C/C++ Compilers
#==========================
#==  MAKING GCC STAGE 1  ==
#==========================


build_gcc_stage1()
{
	header "building gcc stage1"
	GCC_CONFIG="--target=$TARGET --prefix=$TOOLCHAIN_INSTALL_DIR --disable-nls --disable-bootstrap --enable-languages=c"

	cd $GCC_BUILD_DIR
	$GCC_SRC_DIR/configure $GCC_CONFIG
	make -j8  all-gcc
	make   install-gcc
	header "successfully built  gcc stage1"
}


# Step 4. Standard C Library Headers and Startup Files
#============================
#==  MAKING GLIBC HEADERS  ==
#============================

build_glibc_headers()
{
	header "building glibc headers"
#	GLIBC_CONFIG="CC=$TARGET-gcc CXX=$TARGETfake-g++ --build=$MACHTYPE --host=$TARGET --target=$TARGET --prefix=$TOOLCHAIN_INSTALL_DIR/$TARGET --with-headers=$TOOLCHAIN_INSTALL_DIR/$TARGET/include libc_cv_forced_unwind=yes"

	GLIBC_CONFIG=" --build=$MACHTYPE --host=$TARGET --target=$TARGET --prefix=$TOOLCHAIN_INSTALL_DIR/$TARGET --with-headers=$TOOLCHAIN_INSTALL_DIR/$TARGET/include"


	cd $GLIBC_BUILD_DIR
	$GLIBC_SRC_DIR/configure $GLIBC_CONFIG 
	make install-bootstrap-headers=yes install-headers
	make -j8  csu/subdir_lib
	install csu/crt1.o csu/crti.o csu/crtn.o $TOOLCHAIN_INSTALL_DIR/$TARGET/lib
	$TOOLCHAIN_INSTALL_DIR/bin/$TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $TOOLCHAIN_INSTALL_DIR/$TARGET/lib/libc.so
	touch $TOOLCHAIN_INSTALL_DIR/$TARGET/include/gnu/stubs.h
	header "success:built glibc headers"
}

# Step 5. Compiler Support Library
#==========================
#==  MAKING GCC STAGE 2  ==
#==========================
build_gcc_stage2()
{
	cd $GCC_BUILD_DIR
	make -j8  all-target-libgcc
	make install-target-libgcc
}

# Step 6. Standard C Library & the rest of Glibc
#====================
#==  MAKING GLIBC  ==
#====================
build_glibc()
{
	cd $GLIBC_BUILD_DIR
	make -j8
	make install
}

# Step 7. Standard C++ Library & the rest of GCC
#========================
#==  MAKING GCC FINAL  ==
#========================
build_gcc_final()
{
	header "building gcc final"
	cd $GCC_BUILD_DIR
	make -j8  all
	make install
	header "gcc succesfully built"
}

#==================
#==  MAKING GDB  ==
#==================
build_gdb()
{
	header "building gdb"
	GDB_CONFIG="--target=$TARGET --prefix=$TOOLCHAIN_INSTALL_DIR --disable-binutils --disable-ld --disable-gas --with-expat"

	cd $GDB_BUILD_DIR
	$GDB_SRC_DIR/configure $GDB_CONFIG
	make -j8
	make install
	header "built GDB SUCCESSFULLY"
}

cleanup_toolchain()
{
	rm -Rf $TOOLCHAIN_INSTALL_DIR
}

cleanup_build_dir()
{
       rm -Rf $BUILD_DIR 
}





#cleanup_toolchain
#cleanup_build_dir
#download_sources
#copy_sources

#prepare_gcc_src

#prepare_build_dir
#prepare_install_dir
set_environment

#build_binutils
#install_linux_headers
#build_gcc_stage1
#build_glibc_headers
#build_gcc_stage2
#build_glibc
#build_gcc_final
build_gdb


