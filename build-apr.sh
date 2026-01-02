#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=apr

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS=""

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

sed -i -e '/sizeof(off_t/s#!= 4#!= 8#' configure
sed -i -e '/4yes/s/4yes/8yes/' configure

export CPPFLAGS="-D_FILE_OFFSET_BITS=64"

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--enable-threads \
	--enable-posix-shm \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

