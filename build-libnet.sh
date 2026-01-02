#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libnet

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS=""

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh
. $MEDIR/phase-default-config.sh

sed -i -e '/^SUBDIRS/s/doc//' Makefile

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

