#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=liblognorm

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

#DEPS="libestr-dev libfastjson-dev pcre21042-dev"
DEPS="libestr-dev libfastjson-dev pcre-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

autoreconf -i
./configure \
	--enable-shared \
	--enable-regexp \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/bin $TCZ/usr/local

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

