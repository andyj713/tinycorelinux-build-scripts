#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=$1

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="tcl8.6 tcl8.6-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh
. $MEDIR/phase-default-config.sh
. $MEDIR/phase-default-make-install.sh

make install DESTDIR=$TCZ

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/man $TCZ-doc/usr/local

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

