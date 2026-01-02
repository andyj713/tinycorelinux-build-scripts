#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libjudy

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS=""

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

#	--enable-64-bit \

./configure \
	--enable-shared \
	--disable-static \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/share $TCZ-doc/usr/local

mkdir -p $TCZ-dev/usr/local
mv $TCZ/usr/local/include $TCZ-dev/usr/local

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

