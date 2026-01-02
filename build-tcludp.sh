#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=tcludp

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="tcl8.6 tcl8.6-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

export LDFLAGS="-lm"

./configure \
        --prefix=/usr/local \
        --localstatedir=/var \
        --disable-rpath \
        --enable-64bit \
        --enable-threads \
        --enable-shared \
        || exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

chmod -R ug+w $TCZ

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

