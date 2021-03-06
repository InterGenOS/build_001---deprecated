#!/bin/bash
###  InterGenOS build_temp_sys.sh - Build the Temporary System used to create the working system separately from the host 
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  2/23/2015

cd /mnt/igos

sed -i '/.\/build_temp_sys.sh/d' /home/igos/.bashrc

#######################
## binutils 1st pass ##
#######################

cd /mnt/igos/sources

tar xf binutils-2.24.tar.bz2 &&

cd binutils-2.24

mkdir -v ../binutils-build &&
cd ../binutils-build

../binutils-2.24/configure     \
    --prefix=/tools            \
    --with-sysroot=$IGos       \
    --with-lib-path=/tools/lib \
    --target=$IGos_TGT         \
    --disable-nls              \
    --disable-werror &&
make &&

case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac

make install &&

cd /mnt/igos/sources

rm -rf binutils-build binutils-2.24

##################
## gcc 1st pass ##
##################

tar xf gcc-4.9.1.tar.bz2 &&

cd gcc-4.9.1

tar -xf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -xf ../gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar -xf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure

sed -i 's/if \((code.*))\)/if (\1 \&\& \!DEBUG_INSN_P (insn))/' gcc/sched-deps.c

mkdir -v ../gcc-build
cd ../gcc-build

../gcc-4.9.1/configure                               \
    --target=$IGos_TGT                               \
    --prefix=/tools                                  \
    --with-sysroot=$IGos                             \
    --with-newlib                                    \
    --without-headers                                \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --disable-nls                                    \
    --disable-shared                                 \
    --disable-multilib                               \
    --disable-decimal-float                          \
    --disable-threads                                \
    --disable-libatomic                              \
    --disable-libgomp                                \
    --disable-libitm                                 \
    --disable-libquadmath                            \
    --disable-libsanitizer                           \
    --disable-libssp                                 \
    --disable-libvtv                                 \
    --disable-libcilkrts                             \
    --disable-libstdc++-v3                           \
    --enable-languages=c,c++ &&
make &&
make install &&

cd /mnt/igos/sources

rm -rf gcc-4.9.1 gcc-build

###########################
## Install Linux Headers ##
###########################

tar xf linux-3.18.2.tar.xz &&

cd linux-3.18.2

make mrproper &&

make INSTALL_HDR_PATH=dest headers_install &&

cp -rv dest/include/* /tools/include &&
    
cd /mnt/igos/sources

rm -rf linux-3.18.2

####################
## glibc 1st pass ##
####################

tar xf glibc-2.20.tar.xz &&

cd glibc-2.20

if [ ! -r /usr/include/rpc/types.h ]; then
  su -c 'mkdir -pv /usr/include/rpc'
  su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
fi

mkdir -v ../glibc-build
cd ../glibc-build

../glibc-2.20/configure                             \
      --prefix=/tools                               \
      --host=$IGos_TGT                              \
      --build=$(../glibc-2.20/scripts/config.guess) \
      --disable-profile                             \
      --enable-kernel=2.6.32                        \
      --with-headers=/tools/include                 \
      libc_cv_forced_unwind=yes                     \
      libc_cv_ctors_header=yes                      \
      libc_cv_c_cleanup=yes &&

make &&
make install &&

##########################
## glibc sanity testing ##
##########################

echo 'main(){}' > dummy.c
$IGos_TGT-gcc dummy.c

Expected="Requestingprograminterpreter/tools/lib64/ld-linux-x86-64.so.2"
Actual="$(readelf -l a.out | grep ': /tools' | sed s/://g | cut -d '[' -f 2 | cut -d ']' -f 1 | awk '{print $1$2$3$4}')"

if [ $Expected != $Actual ]; then
    echo "!!!!!GLIBC 1st PASS SANITY CHECK FAILED!!!!! Halting build, check your work."
    exit 0
else
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo "Compiler and Linker are functioning as expected, continuing build."
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
fi

rm -v dummy.c a.out

cd /mnt/igos/sources

rm -rf glibc-build glibc-2.20

#############################
## libstdc++ (part of gcc) ##
#############################

tar xf gcc-4.9.1.tar.bz2 &&

cd gcc-4.9.1

mkdir -pv ../gcc-build
cd ../gcc-build

../gcc-4.9.1/libstdc++-v3/configure \
    --host=$IGos_TGT                \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-shared                \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$IGos_TGT/include/c++/4.9.1 &&
make &&
make install &&

cd /mnt/igos/sources

rm -rf gcc-4.9.1 gcc-build


#######################
## binutils 2nd pass ##
#######################

tar xf binutils-2.24.tar.bz2 &&

cd binutils-2.24

mkdir -v ../binutils-build
cd ../binutils-build

CC=$IGos_TGT-gcc               \
AR=$IGos_TGT-ar                \
RANLIB=$IGos_TGT-ranlib        \
../binutils-2.24/configure     \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot &&
make &&
make install &&

make -C ld clean &&
make -C ld LIB_PATH=/usr/lib:/lib &&
cp -v ld/ld-new /tools/bin &&

cd /mnt/igos/sources

rm -rf binutils-2.24 binutils-build


##################
## gcc 2nd pass ##
##################

tar xf gcc-4.9.1.tar.bz2 &&

cd gcc-4.9.1

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($IGos_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

tar -xf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -xf ../gmp-6.0.0a.tar.xz
mv -v gmp-6.0.0 gmp
tar -xf ../mpc-1.0.2.tar.gz
mv -v mpc-1.0.2 mpc

sed -i 's/if \((code.*))\)/if (\1 \&\& \!DEBUG_INSN_P (insn))/' gcc/sched-deps.c

mkdir -v ../gcc-build
cd ../gcc-build

CC=$IGos_TGT-gcc                                     \
CXX=$IGos_TGT-g++                                    \
AR=$IGos_TGT-ar                                      \
RANLIB=$IGos_TGT-ranlib                              \
../gcc-4.9.1/configure                               \
    --prefix=/tools                                  \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --enable-languages=c,c++                         \
    --disable-libstdcxx-pch                          \
    --disable-multilib                               \
    --disable-bootstrap                              \
    --disable-libgomp &&
make &&
make install &&
ln -sv gcc /tools/bin/cc

########################
## gcc sanity testing ##
########################

echo 'main(){}' > dummy.c
cc dummy.c

Expected2="Requestingprograminterpreter/tools/lib64/ld-linux-x86-64.so.2"
Actual2="$(readelf -l a.out | grep ': /tools' | sed s/://g | cut -d '[' -f 2 | cut -d ']' -f 1 | awk '{print $1$2$3$4}')"

if [ $Expected2 != $Actual2 ]; then
    echo "!!!!!GCC 2nd PASS SANITY CHECK FAILED!!!!! Halting build, check your work."
    exit 0
else
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo "Compiler and Linker are functioning as expected, continuing build."
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
    echo " "
fi

rm -v dummy.c a.out

cd /mnt/igos/sources

rm -rf gcc-4.9.1 gcc-build

#########
## tcl ##
#########

tar xf tcl8.6.2-src.tar.gz &&

cd tcl8.6.2

cd unix
./configure --prefix=/tools &&

make &&

make install &&

chmod -v u+w /tools/lib/libtcl8.6.so

make install-private-headers &&

ln -sv tclsh8.6 /tools/bin/tclsh

cd /mnt/igos/sources

rm -rf tcl8.6.2


############
## expect ##
############

tar xf expect5.45.tar.gz &&

cd expect5.45

cp -v configure{,.orig} &&
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include &&
make &&

make SCRIPTS="" install &&

cd /mnt/igos/sources

rm -rf expect5.45

#############
## dejagnu ##
#############

tar xf dejagnu-1.5.1.tar.gz &&

cd dejagnu-1.5.1

./configure --prefix=/tools &&

make install &&

cd /mnt/igos/sources

rm -rf dejagnu-1.5.1


###########
## check ##
###########

tar xf check-0.9.14.tar.gz &&

cd check-0.9.14

PKG_CONFIG= ./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf check-0.9.14


#############
## ncurses ##
#############

tar xf ncurses-5.9.tar.gz &&

cd ncurses-5.9

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite &&
make &&

make install &&

cd /mnt/igos/sources

rm -rf ncurses-5.9


##########
## bash ##
##########

tar xf bash-4.3.tar.gz &&

cd bash-4.3

patch -Np1 -i ../bash-4.3-upstream_fixes-3.patch &&

./configure --prefix=/tools --without-bash-malloc &&

make &&

make install &&

ln -sv bash /tools/bin/sh

cd /mnt/igos/sources

rm -rf bash-4.3


###########
## bzip2 ##
###########

tar xf bzip2-1.0.6.tar.gz &&

cd bzip2-1.0.6

make &&

make PREFIX=/tools install &&

cd /mnt/igos/sources

rm -rf bzip2-1.0.6


###############
## coreutils ##
###############

tar xf coreutils-8.23.tar.xz &&

cd coreutils-8.23

./configure --prefix=/tools --enable-install-program=hostname &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf coreutils-8.23


###############
## diffutils ##
###############

tar xf diffutils-3.3.tar.xz &&

cd diffutils-3.3

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf diffutils-3.3


##########
## file ##
##########

tar xf file-5.19.tar.gz &&

cd file-5.19

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf file-5.19


###############
## findutils ##
###############

tar xf findutils-4.4.2.tar.gz &&

cd findutils-4.4.2

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf findutils-4.4.2


##########
## gawk ##
##########

tar xf gawk-4.1.1.tar.xz &&

cd gawk-4.1.1

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf gawk-4.1.1


#############
## gettext ##
#############

tar xf gettext-0.19.2.tar.xz &&

cd gettext-0.19.2

cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared &&

make -C gnulib-lib &&
make -C src msgfmt &&
make -C src msgmerge &&
make -C src xgettext &&

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin &&

cd /mnt/igos/sources

rm -rf gettext-0.19.2


##########
## grep ##
##########

tar xf grep-2.20.tar.xz &&

cd grep-2.20

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf grep-2.20


##########
## gzip ##
##########

tar xf gzip-1.6.tar.xz &&

cd gzip-1.6

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf gzip-1.6


########
## m4 ##
########

tar xf m4-1.4.17.tar.xz &&

cd m4-1.4.17

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf m4-1.4.17


##########
## make ##
##########

tar xf make-4.0.tar.bz2 &&

cd make-4.0

./configure --prefix=/tools --without-guile &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf make-4.0


###########
## patch ##
###########

tar xf patch-2.7.1.tar.xz &&

cd patch-2.7.1

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf patch-2.7.1


##########
## perl ##
##########

tar xf perl-5.20.0.tar.bz2 &&

cd perl-5.20.0

sh Configure -des -Dprefix=/tools -Dlibs=-lm &&

make &&

cp -v perl cpan/podlators/pod2man /tools/bin &&
mkdir -pv /tools/lib/perl5/5.20.0
cp -Rv lib/* /tools/lib/perl5/5.20.0 &&

cd /mnt/igos/sources

rm -rf perl-5.20.0


#########
## sed ##
#########

tar xf sed-4.2.2.tar.bz2 &&

cd sed-4.2.2

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf sed-4.2.2


#########
## tar ##
#########

tar xf tar-1.28.tar.xz &&

cd tar-1.28

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf tar-1.28


#############
## texinfo ##
#############

tar xf texinfo-5.2.tar.xz &&

cd texinfo-5.2

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf texinfo-5.2


################
## util-linux ##
################

tar xf util-linux-2.25.1.tar.xz &&

cd util-linux-2.25.1

./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            PKG_CONFIG="" &&
make &&

make install &&

cd /mnt/igos/sources

rm -rf util-linux-2.25.1


########
## xz ##
########

tar xf xz-5.0.5.tar.xz &&

cd xz-5.0.5

./configure --prefix=/tools &&

make &&

make install &&

cd /mnt/igos/sources

rm -rf xz-5.0.5

###########################################################
## Strip unnecessary debugging symbols and documentation ##
###########################################################

strip --strip-debug /tools/lib/* &&

/usr/bin/strip --strip-unneeded /tools/{,s}bin/* &&

rm -rf /tools/{,share}/{info,man,doc} &&


echo " "
echo " "
echo " "
echo "==================================================================================="
echo "|                                                                                 |"
echo "|                        Temporary System Build Completed                         |"
echo "|                                                                                 |"
echo "|  It is now recommended that you open a separate terminal to back up the /tools  |"
echo "|    directory for future use, as the directory will be altered and eventually    |"
echo "|              removed during the remainder of the build process.                 |"
echo "|                                                                                 |"
echo "|     The remainder of the core system build process must be performed as the     |"
echo "|   root user. Please drop out of this shell and back into the root user shell    |"
echo "|                        in order to proceed with the build.                      |"
echo "|                                                                                 |"
echo "|                                                                                 |"
echo "==================================================================================="
echo " "
echo " "
echo " "
