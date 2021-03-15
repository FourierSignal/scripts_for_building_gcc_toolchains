HOME_DIR=/home/jaguar
REL_PATH=$HOME_DIR/Documents/toolcahins/scripts_for_building_gcc_toolchains
PROJ_DIR=$REL_PATH/baremetal_toolchain_build



SOURCES_DIR=$PROJ_DIR/sources
COMMON_DOWNLOADS_DIR=$REL_PATH/sources_tar_git

BUILD_DIR=$PROJ_DIR/build_dir 
BINUTILS_BUILD_DIR=$BUILD_DIR/build-binutils  
NEWLIB_BUILD_DIR=$BUILD_DIR/build-newlib
GCC_BUILD_DIR=$BUILD_DIR/build-gcc  
GDB_BUILD_DIR=$BUILD_DIR/build-gdb  







BINUTILS_VER=2_35
NEWLIB_VER=2.32
GCC_VER=10
GDB_VER=2_35



BINUTILS_SRC_DIR=$SOURCES_DIR/binutils-$BINUTILS_VER
GCC_SRC_DIR=$SOURCES_DIR/gcc-$GCC_VER
NEWLIB_SRC_DIR=$SOURCES_DIR/newlib-$NEWLIB_VER
GDB_SRC_DIR=$SOURCES_DIR/gdb-$GDB_VER





TOOLCHAIN_INSTALL_DIR=$PROJ_DIR/toolchain
#TARGET=aarch64-elf
TARGET=aarch64-unknown-elf
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

    #unzip newlib-$NEWLIB_VER.zip -d $NEWLIB_VER

    git clone --depth=1 git://sourceware.org/git/glibc.git $GLIBC_SRC_DIR -b glibc-$GLIBC_VER
    git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git $LINUX_SRC_DIR -b $LINUX_VER
    git clone --depth=1 git://sourceware.org/git/binutils-gdb.git $BINUTILS_SRC_DIR -b binutils-$BINUTILS_VER
    git clone --depth=1 git://gcc.gnu.org/git/gcc.git $GCC_SRC_DIR -b releases/gcc-$GCC_VER
    git clone --depth=1 git://sourceware.org/git/binutils-gdb.git $GDB_SRC_DIR -b gdb-$GDB_VER

    #wget -nc https://www.kernel.org/pub/linux/kernel/v3.x/$LINUX_KERNEL_VERSION.tar.xz
    #wget -nc https://ftp.gnu.org/gnu/glibc/$GLIBC_VERSION.tar.xz

    wget -c https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VER.tar.gz
    tar xvf mpc-$MPC_VER.tar.gz -C $MPC_SRC_DIR  --strip-components=1

    wget -c http://isl.gforge.inria.fr/isl-$ISL_VER.tar.xz
    tar xvf isl-$ISL_VER.tar.xz -C $ISL_SRC_DIR --strip-components=1

    wget -c https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VER.tar.xz
    tar xvf mpfr-$MPFR_VER.tar.xz -C $MPFR_SRC_DIR --strip-components=1

    wget -c https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VER.tar.xz
    tar xvf gmp-$GMP_VER.tar.xz -C $GMP_SRC_DIR --strip-components=1

    wget -c http://www.bastoul.net/cloog/pages/download/cloog-$CLOOG_VER.tar.gz
    tar xvf cloog-$CLOOG_VER.tar.gz -C $CLOOG_SRC_DIR --strip-components=1
}

copy_sources()
{
	mkdir -p $SOURCES_DIR
	echo "copy all sources"
	cp -R $COMMON_DOWNLOADS_DIR/* $SOURCES_DIR/
	cd $SOURCE_DIR
    	unzip newlib-$NEWLIB_VER.zip -d $NEWLIB_VER
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
	mkdir -p $BUILD_DIR
	mkdir -p $BINUTILS_BUILD_DIR 
	mkdir -p $NEWLIB_BUILD_DIR
	mkdir -p $GCC_BUILD_DIR  
	mkdir -p $GDB_BUILD_DIR  
}

prepare_install_dir()
{
	#sudo mkdir -p $TOOLCHAIN_INSTALL_DIR
	#sudo chown jaguar:jaguar $TOOLCHAIN_INSTALL_DIR
	mkdir -p $TOOLCHAIN_INSTALL_DIR
	

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

# Step 2. C/C++ Compilers
#==========================
#==  MAKING GCC STAGE 1  ==
#==========================

build_gcc_stage1()
{
	header "building gcc stage1"
	GCC_CONFIG="--target=$TARGET --prefix=$TOOLCHAIN_INSTALL_DIR  --with-newlib   --disable-nls --disable-bootstrap --enable-languages=c"

	cd $GCC_BUILD_DIR
	$GCC_SRC_DIR/configure $GCC_CONFIG
	make   all-gcc
	make   install-gcc
	header "successfully built  gcc stage1"
}


#step3: build newlib
#============================
#==  MAKING NEWLIB  ==
#============================
build_newlib()
{
	header "building newlib"
	NEWLIB_CONFIG="--prefix=$TOOLCHAIN_INSTALL_DIR  --target=$TARGET --disable-multilib"

	cd $NEWLIB_BUILD_DIR
	$NEWLIB_SRC_DIR/configure $NEWLIB_CONFIG
	make -j8 
	make install
	header "building newlib SUCCESS"
}


# Step 4. build the rest of GCC
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


check_directories()
{
	echo $PROJ_DIR
	echo $COMMON_DOWNLOADS_DIR
	ls $COMMON_DOWNLOADS_DIR/
	echo $SOURCES_DIR
    exit
}

#check_directories
cleanup_toolchain
cleanup_build_dir

#download_sources
copy_sources

prepare_gcc_src

prepare_build_dir
prepare_install_dir
set_environment
build_binutils
build_gcc_stage1
build_newlib
build_gcc_final
build_gdb


