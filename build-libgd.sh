#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libgd

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="automake libtool-dev perl5 libpng-dev fontconfig-dev libwebp1-dev"

case $TCVER in
	64-17 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-17 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-16 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-16 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-15 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-15 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-14 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-14 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-13 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-13 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-12 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-12 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-11 ) DEPS="$DEPS libvpx18-dev tiff-dev" ;;
	32-11 ) DEPS="$DEPS libvpx18-dev libtiff-dev" ;;
	64-10 ) DEPS="$DEPS libvpx17-dev tiff-dev" ;;
	32-10 ) DEPS="$DEPS libvpx17-dev libtiff-dev" ;;
	* ) DEPS="$DEPS libvpx-dev"; test $KBITS = 64 && DEPS="$DEPS tiff-dev" || DEPS="$DEPS libtiff-dev" ;;
esac

def_deps
ccxx_opts lto noex

./configure \
	--without-x \
	--without-xpm \
	|| exit

def_make
make_dev

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib

mkdir -p $TCZ-bin/usr/local
mv $TCZ-dev/usr/local/bin $TCZ-bin/usr/local

mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ-bin/usr/local/bin/gdlib-config $TCZ-dev/usr/local/bin

def_strip
set_perms
squash_tcz

