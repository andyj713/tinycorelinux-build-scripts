#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libdnet

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="libtool-dev autoconf automake"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-no-flto.sh

export LDFLAGS="-lm"

#sh ./autogen.sh

./configure \
	--disable-check \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh

mv $TCZ-dev/usr/local/sbin $TCZ/usr/local
mkdir -p $TCZ-dev/usr/local/share
mv $TCZ-dev/usr/local/man $TCZ-dev/usr/local/share

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

