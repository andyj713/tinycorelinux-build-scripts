#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libzip

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="cmake groff liblzma-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_GNUTLS=OFF

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh

mkdir -p $TCZ-bin/usr/local
mv $TCZ-dev/usr/local/bin $TCZ-bin/usr/local

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

