
#/home/jaguar/Documents/toolcahins/scripts_for_building_gcc_toolchains

HOME_DIR=/home/jaguar
REL_PATH=$HOME_DIR/Documents/toolcahins/scripts_for_building_gcc_toolchains
PROJ_DIR=$REL_PATH


COMMON_DOWNLOADS_DIR=$PROJ_DIR/sources_tar_git

BINUTILS_VER=2_35
GLIBC_VER=2.32
LINUX_VER=v5.6
GCC_VER=10
GDB_VER=2_35



BINUTILS_SRC_DIR=$COMMON_DOWNLOADS_DIR/binutils-$BINUTILS_VER
GCC_SRC_DIR=$COMMON_DOWNLOADS_DIR/gcc-$GCC_VER
GLIBC_SRC_DIR=$COMMON_DOWNLOADS_DIR/glibc-$GLIBC_VER
GDB_SRC_DIR=$COMMON_DOWNLOADS_DIR/gdb-$GDB_VER
LINUX_SRC_DIR=$COMMON_DOWNLOADS_DIR/linux-$LINUX_VER



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
     mkdir -p $COMMON_DOWNLOADS_DIR
     cd $COMMON_DOWNLOADS_DIR
     echo "Downloading into $COMMON_DOWNLOADS_DIR"
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



download_sources


