#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=jemalloc

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="libtool-dev autoconf automake"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-flto.sh

./autogen.sh

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

