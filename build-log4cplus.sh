#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=log4cplus

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh
. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-flto.sh

export CXXFLAGS="$CXXFLAGS -fexceptions"

./configure \
	--enable-lto \
	--with-iconv \
	--with-wchar_t-support \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

