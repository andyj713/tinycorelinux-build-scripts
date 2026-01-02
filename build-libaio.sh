#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libaio

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS=""

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-no-flto.sh

for a in $(cat debian/patches/series); do sed -n '/--- [^ ]*$/,$p' debian/patches/$a | patch -N -p1; done

sed -i -e '/^prefix/s#/usr#/usr/local#' src/Makefile
sed -i -e '/MK_CFLAGS=/s/-nostdlib //' src/Makefile

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

