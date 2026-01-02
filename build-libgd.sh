#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libgd

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="automake libtool-dev perl5 libpng-dev fontconfig-dev libwebp1-dev"

case $TCVER in
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

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

./configure \
	--without-x \
	--without-xpm \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib

mkdir -p $TCZ-bin/usr/local
mv $TCZ-dev/usr/local/bin $TCZ-bin/usr/local

mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ-bin/usr/local/bin/gdlib-config $TCZ-dev/usr/local/bin

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

