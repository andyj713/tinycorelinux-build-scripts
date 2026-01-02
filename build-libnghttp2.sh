#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libnghttp2

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS=""

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

make clean
./configure \
	--enable-lib-only \
	--disable-python-bindings \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

mkdir -p $TCZ/usr/local/libexec
mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/share/nghttp2 $TCZ/usr/local/libexec
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

